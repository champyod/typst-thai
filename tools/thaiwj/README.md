# thaiwj — Thai newline engine

Small C tool (libthai) that bakes U+2060 word joiners inside Thai words so
a typesetter only breaks lines at word boundaries, never mid-word.

## Build

```sh
gcc -O2 -o thaiwj thaiwj.c -lthai
```

## Use

```sh
./thaiwj INPUT.typ OUTPUT.typ [--hyphen [SYLLABLES]]
```

Word joiners are inserted between adjacent Thai letters that belong to the
same word (boundaries come from `th_brk_wc_insert_breaks`, whose output was
verified correct against `th_brk_wc_find_breaks`). Everything else,
including Typst markup, is passed through untouched. Running twice is safe
(idempotent).

With `--hyphen`, words listed in SYLLABLES (`word=syl|la|bles` per line)
get U+00AD soft hyphens at those curated subword joints instead of
joiners, so abnormally long words may break there when they do not fit.
Priority, highest first: word joiner (never break) > soft-hyphen joints
(break only if needed) > word joints (free). Note the engine breaks soft
hyphens silently (no dash is rendered); formal documents that forbid
hyphenation keep the flag off (default).
