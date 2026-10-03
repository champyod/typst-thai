# Typst (Thai fork)

This is a fork of [typst/typst](https://github.com/typst/typst) with Thai
typesetting support, maintained for producing Thai academic documents until
the upstream project ships equivalent features.

## Upstream credit

Thai distributed justification comes from pull request
[typst/typst#8617](https://github.com/typst/typst/pull/8617)
(`feat/par: add Thai distributed justification`) by
[ChilG](https://github.com/ChilG), opened for
[issue #8413](https://github.com/typst/typst/issues/8413)
(Thai text justification support). All justification design in that change
is their work.

## Line-break rules (kept as-is)

Breaks happen only at word joints, never inside a word or grapheme
cluster. This follows the W3C Thai Gap Analysis
([thai-gap](https://www.w3.org/TR/thai-gap/), sections 5.2, 7.1, 7.2):
Thai wraps whole words (spaces separate phrases, not words), combining
marks never separate from their base, and justification adjusts phrase
spaces first with inter-character spacing only where a spaceless run
overflows the line. Subword joints from the dictionary (prefix-style
joints such as การ|แข่งขัน) are kept, matching common Thai breakers.

## Our own changes

- Merged `pr-thai` (`feat/thai-distributed-justification`) onto current
  `main` (`b6fd55eeb`).
- Adapted the PR to the current `Item` API: replaced the removed
  `ItemEntry::is_tag()` with `is_skippable()` in
  `crates/typst-layout/src/inline/line.rs`
  (`3e6a8bc14`). Same skip-tags-while-scanning behavior, no logic change.
- Added `tools/thaiwj/`: the Thai newline engine (C + libthai). It finds
  word boundaries with the libthai dictionary and bakes U+2060 word
  joiners inside words so lines never break mid-word. Break priority,
  highest first: word joiner (never break) > soft-hyphen joints from
  `tools/thaiwj/syllables.txt` (break only if needed, curated subword
  joints for long loanwords) > word joints (free). Soft hyphens break
  silently: the engine renders no dash, so formal documents keep
  hyphenation off (`HYPHEN=0`). See `tools/thaiwj/README.md`.

## Build

```sh
cargo build --release --bin typst
./target/release/typst --version
```

Requires a Rust toolchain (tested with rustc 1.98) and network access for
crates.io on first build.

## System dependency

The binary links the system libthai, so both of its packages must be
installed before building:

```sh
sudo apt install -y libthai-dev libthai-data
```

`libthai-data` is not optional. It is a separate package on Ubuntu and it is
the one carrying `thbrk.tri`; without it the binary links fine and then
segments nothing at runtime.

At runtime the binary needs `libthai0` present, which is a small library that
is packaged essentially everywhere, and `THAI_DICT_PATH` pointing at the
`thbrk.tri` shipped in the release archive:

```sh
tar xJf typst-x86_64-unknown-linux-gnu.tar.xz
export THAI_DICT_PATH="$PWD/typst-x86_64-unknown-linux-gnu/share/libthai/thbrk.tri"
```

`crates/typst-layout/src/inline/linebreak.rs` reads that variable and passes
it straight to `th_brk_new`, bypassing all three of libthai's own dictionary
lookup layers. Without it `th_brk_new(NULL)` resolves the dictionary through
the path compiled into libthai at build time, which does not exist on your
machine.

Release archives are published for `x86_64-unknown-linux-gnu`. Other
architectures, including 64-bit ARM for Raspberry Pi, are not built yet.

## Use

```typ
#set text(lang: "th")
#set par(justify: true, thai-distributed: true)
```

## Archive notice

This fork may be archived after some period, or as soon as the upstream
project merges equivalent Thai justification support (PR #8617 or
successor). When that happens, switch back to upstream Typst.
