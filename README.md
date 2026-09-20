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

## Our own changes

- Merged `pr-thai` (`feat/thai-distributed-justification`) onto current
  `main` (`b6fd55eeb`).
- Adapted the PR to the current `Item` API: replaced the removed
  `ItemEntry::is_tag()` with `is_skippable()` in
  `crates/typst-layout/src/inline/line.rs`
  (`3e6a8bc14`). Same skip-tags-while-scanning behavior, no logic change.
- Added `tools/thaiwj/`: the Thai newline engine (C + libthai). It finds
  word boundaries with the libthai dictionary and bakes U+2060 word
  joiners inside words so lines never break mid-word. See
  `tools/thaiwj/README.md`.

## Build

```sh
cargo build --release --bin typst
./target/release/typst --version
```

Requires a Rust toolchain (tested with rustc 1.98) and network access for
crates.io on first build.

## Use

```typ
#set text(lang: "th")
#set par(justify: true, thai-distributed: true)
```

## Archive notice

This fork may be archived after some period, or as soon as the upstream
project merges equivalent Thai justification support (PR #8617 or
successor). When that happens, switch back to upstream Typst.
