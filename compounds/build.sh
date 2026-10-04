#!/usr/bin/env bash
#
# Builds a merged Thai segmentation dictionary: the distro's thbrk.tri plus every
# word list in data/. The base trie is never modified; everything happens on a
# copy under build/, which is safe to delete at any time.
#
# Usage: ./build.sh [output-dir]        default ./build
#
# Requires trietool (libdatrie). See README.md for the per-platform package name.
set -euo pipefail

script_dir() { cd "$(dirname "${BASH_SOURCE[0]}")" && pwd; }
ROOT="$(script_dir)"

out_dir="${1:-$ROOT/build}"
base_trie="${THAI_BASE_TRIE:-/usr/share/libthai/thbrk.tri}"

fail() { echo "build.sh: $*" >&2; exit 1; }

command -v trietool > /dev/null 2>&1 || command -v trietool-0.2 > /dev/null 2>&1 \
  || fail "trietool not found. Install libdatrie (see README.md)."
TRIETOOL="$(command -v trietool || command -v trietool-0.2)"

[ -r "$base_trie" ] || fail "base trie not readable: $base_trie
  Set THAI_BASE_TRIE to the thbrk.tri your distro installs."

mkdir -p "$out_dir"
merged="$out_dir/thbrk.tri"

# trietool has no comment syntax: it treats every line as a key, including blank
# lines and '#' lines, and reports each as 'Failed to add key'. Worse, those
# failures go to stderr and still exit 0, so a naive call looks successful. Filter
# here and treat any remaining stderr as a hard failure.
stage_list() {
  local source="$1" staged="$2"
  : > "$staged"
  local line kept=0
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    case "$line" in
      '#'*|'') continue ;;
    esac
    if [[ "$line" =~ [[:space:]] ]]; then
      # A key containing a space can never match: th_brk_find_breaks splits the
      # input into per-class chunks before the trie is consulted.
      echo "build.sh: dropping entry containing whitespace: $line" >&2
      continue
    fi
    printf '%s\n' "$line" >> "$staged"
    kept=$((kept + 1))
  done < "$source"
  [ "$kept" -gt 0 ] || fail "no usable entries in $source"
  echo "$kept"
}

lists=()
while IFS= read -r list; do
  lists+=("$list")
done < <(find "$ROOT/data" -maxdepth 1 -type f -name '*.txt' | LC_ALL=C sort)

if [ "${#lists[@]}" -eq 0 ]; then
  fail "no word lists found in $ROOT/data"
fi

# Work on a copy: trietool rewrites <path>/<name>.tri in place.
cp "$base_trie" "$merged" || fail "could not copy $base_trie to $merged"

echo "base   : $base_trie ($(wc -c < "$base_trie") bytes)"
for list in "${lists[@]}"; do
  staged="$out_dir/.$(basename "$list").staged"
  # stage_list prints the kept count on stdout and warnings on stderr, so command
  # substitution captures only the number while warnings still reach the terminal.
  kept="$(stage_list "$list" "$staged")"
  # -e utf-8 is required: trietool iconv's from the locale charset, which is not
  # UTF-8 unless the environment says so.
  stderr_file="$out_dir/.$(basename "$list").err"
  if ! "$TRIETOOL" -p "$out_dir" thbrk add-list -e utf-8 "$staged" 2> "$stderr_file"; then
    cat "$stderr_file" >&2
    fail "trietool exited non-zero on $(basename "$list")"
  fi
  if [ -s "$stderr_file" ]; then
    cat "$stderr_file" >&2
    rm -f "$staged" "$stderr_file"
    fail "trietool reported failures while merging $(basename "$list")"
  fi
  rm -f "$staged" "$stderr_file"
  echo "merged : $(basename "$list") ($kept entries)"
done

echo "result : $merged ($(wc -c < "$merged") bytes)"

# Verify the merge took: an entry added a moment ago must be present, and a word
# the base already had must have survived.
check() {
  local word="$1" expected="$2" got
  got="$("$TRIETOOL" -p "$out_dir" thbrk query "$word" 2>&1 || true)"
  if [ "$got" != "$expected" ]; then
    fail "verification failed for $word: expected $expected, got $got"
  fi
  echo "ok     : $word -> $got"
}
# -1 is libdatrie's "stored, no data field", which is what libthai's own build
# writes and what brk-maximal.c ignores.
check 'ขั้นตอน' -1
check 'หน่วยความจำ' -1
check 'ล่าสุด' -1

echo
echo "Use it with:"
echo "  export THAI_DICT_PATH=\"$merged\""