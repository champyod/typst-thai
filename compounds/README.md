# Thai compound groups

A supplementary dictionary for [typst-thai](https://github.com/champyod/typst-thai).
It holds Thai technical compounds that must not be split across a line break.

## What an entry does

libthai segments Thai with **maximal matching** over the words in its trie: at each
position it takes the longest dictionary entry it can reach. A compound that is
*absent* from the trie therefore gets split into its parts, even when the whole is
the word a reader sees.

Measured on this machine against `thbrk.tri` 0.1.30:

| Input | Without this list | With this list |
| --- | --- | --- |
| `หน่วยความจำ` | `หน่วย / ความ / จำ` | `หน่วยความจำ` |
| `เครือข่ายคอมพิวเตอร์` | `เครือข่าย / คอมพิวเตอร์` | `เครือข่ายคอมพิวเตอร์` |
| `รุ่นล่าสุด` | `รุ่น / ล่า / สุด` | `รุ่นล่าสุด` |

**An entry makes that string unbreakable everywhere it occurs.** That is the point,
and also the risk — see *One-way door* below.

## How it works: no code change

`trietool add-list` is a load-modify-save tool, not a compiler. It opens an existing
`.tri`, merges words into it, and writes it back. So the whole mechanism is:

1. copy the distro's `thbrk.tri`
2. merge this directory's word lists into the copy
3. point `THAI_DICT_PATH` at the result

typst-thai already reads `THAI_DICT_PATH` and hands it to `th_brk_new` ahead of every
path libthai searches itself, so **no line-breaking code changes are involved.**
`linebreak.rs` picks the joints up automatically in both modes:

- **justified text** — ICU's statistical breaks inside the compound are no longer
  dictionary joints, so `hides_thai_break` hides them and the compound stays whole
- **`emergency-break`** — `thai_joints_within` finds no joint inside the compound,
  so no mid-word cut is offered there

## Build

```sh
./build.sh                 # writes ./build/thbrk.tri
export THAI_DICT_PATH="$PWD/build/thbrk.tri"
```

Requires `trietool` from libdatrie:

| Platform | Command |
| --- | --- |
| Debian / Ubuntu | `apt install libdatrie1-bin` |
| Fedora | `dnf install libdatrie` |
| Arch | `pacman -S libdatrie` |
| Alpine | `apk add libdatrie-dev` |
| macOS | `brew install libdatrie` |

The base trie defaults to `/usr/share/libthai/thbrk.tri`; override with
`THAI_BASE_TRIE=/path/to/thbrk.tri ./build.sh`. The base is never modified — the
build works on a copy, and `build/` is disposable.

## Layout

```
data/technical.txt   curated entries. This is the file to edit.
review/candidates.txt mined from the report corpus. NOT merged; a review queue.
build.sh             copy, merge, verify
build/thbrk.tri      generated. Safe to delete at any time.
```

Only `data/*.txt` is merged, in sorted filename order, so adding a file is enough
to add words. One UTF-8 compound per line, **no whitespace inside a line** — a key
containing a space can never match, because `th_brk_find_breaks` splits the input
into per-class chunks before the trie is consulted. `build.sh` drops blank lines,
lines starting with `#`, and any line containing whitespace, counting what it kept
and reporting what it dropped.

`trietool` itself has **no comment syntax** — it treats every line as a key and
reports the rest as `Failed to add key`, while still exiting 0. `build.sh` treats
any output on trietool's stderr as a hard failure, so that cannot pass silently.

`review/candidates.txt` is deliberately outside `data/` for that reason: it holds
proposals, and a proposal that has not been reviewed must not change layout.

## Rules for adding an entry

Add a compound only when **all** of these hold:

- it is a word a reader sees as one unit, not a phrase or clause
- the parts are themselves dictionary words, so the current split is word-to-word
- it is short enough to fit a line — see *Overflow* below

Do **not** add whole clauses. In Thai a clause is an unbroken run just like a
compound is, so nothing in the text distinguishes them; only judgement does. The
single worst entry would be one long enough to force an overfull box on every
occurrence.

## Overflow

A compound becomes unbreakable. If it is wider than the measure, the line will
stretch or overflow rather than cut inside it, because there is no joint left to cut
at. This is correct for the group but costs layout quality on a narrow measure, so
prefer short entries. `emergency-break` still cuts at joints in *other* words of the
same run, so the damage is usually local.

An embedded space defeats any dictionary: `หน่วย ความจำ` will still split, correctly,
because a space is a real boundary.

## One-way door

Merging only ever **removes** break opportunities, and `trietool delete-list` is the
only way to undo it. `build.sh` never touches the base trie, so recovery is always
possible: delete `build/` and you are back to the distro dictionary. An entry that
causes bad segmentation elsewhere — libthai's own ChangeLog records removing a rare
compound `สู่สม` because it produced `สู่สม|ดุล` — should be deleted from
`data/technical.txt` and the build rerun.

## Licence

`data/technical.txt` is original work. No third-party word list is bundled here.

Words are deliberately **not** seeded from these sources:

- **libthai's `data/tdict-*.txt`** — derived from Royal Institute headwords under a
  blanket LGPL with no separate grant from the Royal Society of Thailand. Reusing
  them in a separate project would be a licence-laundering risk.
- **ICU `thaidict`** — Unicode-3.0 carries a redistribution obligation, and its
  26k short-word entries miss every compound this project needs.
- **Wiktionary** — CC BY-SA is share-alike, which a derived word list inherits.

PyThaiNLP's `words_th.txt` is CC0-1.0 and legally clean, and is the right source if
the curated list is ever widened — but a wholesale import turns every multi-word
entry into an unbreakable group and risks overfull boxes, so widen only after
measuring.