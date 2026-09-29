# Benchmark corpus — Thai line-break inputs

Frozen corpus for epic `thai-break-benchmark`, step 1 (corpus freeze).
This directory holds text only. It contains no segmentation, no metrics, and
no threshold/hyphen/policy code.

## Format contract

- Encoding: UTF-8, LF line endings, single trailing newline.
- One unit per line. A unit is one paragraph, one enumerated step, one bullet,
  or one heading as written in the source. Blank lines are not used, so a line
  is always exactly one independent break candidate.
- `wc -c` byte counts below are measured from the files as frozen.

## Extraction rules

Applied uniformly to every file here, so the corpus is reproducible from the
recorded sources:

1. Typst markup is removed: `#import`, `#h1[]`–`#h4[]`, `#p[`, `#enum(`/`)`,
   `[...]` wrappers, `+ ` bullet markers.
2. Citation calls are removed: `#cite(<key>)` and
   `#cite(<key>, form: "prose")`. Any whitespace left behind is collapsed to a
   single space. No placeholder text is substituted.
3. `#raw("...")` keeps its inner string; `$...$` math keeps its literal inner
   source text.
4. Typst `//` comment lines are dropped, as are author placeholder paragraphs
   of the form `[WAITING: ...]` — these are unfinished English notes, not
   project prose.
5. A source unit that spans several source lines is joined into one line;
   internal newlines become single spaces.
6. A unit containing no Thai block character (U+0E00–U+0E7F) is dropped. This
   removes pure-ASCII headings such as `Word Accuracy` and `CPU Latency`.

## Sources

Text comes from two repositories. Both were read clean (`git status` empty)
at the commits below.

| Repository | Commit | Branch | Working tree at freeze |
|---|---|---|---|
| `/mnt/Datas/Champ/Coding/Repos/GOaT-hub/GOaT-Documents` | `0b212732117caa4d235cfd74a0d52fe1da0587c8` | `main` | clean |
| `/mnt/Datas/Champ/Coding/Repos/GOaT-hub/typst-thai` | `c6f1fa1753a263e982f2abe4d0d95c0498069f52` | `main` | clean |

GOaT-Documents is a read-only source for this step; it is out of scope for
modification.

## Files

### `goat-report-intro.txt`

- Origin: `GOaT-Documents/sections/GOAT-report/intro.typ`
- Units: `h1` + 7 `#p` paragraphs
- Lines: 9 — bytes: 9986 — characters: 3516

### `goat-report-problem.txt`

- Origin: `GOaT-Documents/sections/GOAT-report/problem.typ`
- Units: `h1` + 2 `#p` paragraphs
- Lines: 3 — bytes: 1921 — characters: 647

### `goat-report-scope.txt`

- Origin: `GOaT-Documents/sections/GOAT-report/scope.typ`
- Units: `h1` + 4 `#enum` items
- Lines: 5 — bytes: 3048 — characters: 1229

### `goat-report-related-works.txt`

- Origin: `GOaT-Documents/sections/GOAT-report/related_works.typ`
- Units: `h1` + 7 `#p` paragraphs
- Lines: 9 — bytes: 20671 — characters: 7979

### `goat-report-methodology.txt`

- Origin: `GOaT-Documents/sections/GOAT-report/methodology.typ`
- Units: headings, `+` bullets and `#enum` items (list-shaped text)
- Lines: 128 — bytes: 24898 — characters: 10292

### `goat-report-analysis.txt`

- Origin: `GOaT-Documents/sections/GOAT-report/analysis.typ`
- Units: headings, `#p` paragraphs and `#enum` items
- Lines: 74 — bytes: 21401 — characters: 9577

### `fixture-par-distributed.txt`

- Origin: `typst-thai/tests/suite/model/par.typ`, test `par-thai-distributed`
- Units: the single Thai paragraph of that test (line 588)
- Lines: 1 — bytes: 1163 — characters: 419

### `fixture-cluster-linebreak.txt`

- Origin: `typst-thai/tests/suite/layout/inline/linebreak.typ`, test
  `linebreak-thai` (line 61)
- Units: the single Thai consonant-cluster torture string of that test
- Lines: 1 — bytes: 814 — characters: 272

### `fixture-word-boundaries.txt`

- Origins:
  - `typst-thai/crates/typst-layout/src/inline/linebreak.rs`, unit tests
    `thai_word_joints_match_dictionary_segmentation` and
    `intra_word_breaks_hide_but_joints_and_edges_stay`
  - `typst-thai/crates/typst-library/src/model/par.rs`, `thai_distributed`
    doc example
- Units: the Thai string literals those tests exercise — `ฟีเจอร์`,
  `วิศวกรรม`, `การยืนยัน`, `วิศวกรรมความต้องการ`, `การ ยืนยัน`, `ฟีเจอร์X`
  — plus the two doc-example lines
- Lines: 8 — bytes: 457 — characters: 159

## Duplicates excluded

`GOAT-proposal/` carries byte-identical copies of some `GOAT-report/` sections
(`intro.typ`, `related_works.typ` verified identical with `cmp`). Only the
`GOAT-report/` copy is collected, so no source text is counted twice.
`methodology.typ`, `analysis.typ`, `scope.typ` and `problem.typ` differ between
the two document sets; only the `GOAT-report/` variant is collected, for
consistency. `GOAT-slides/` and `GOAT-final-slides/` are not collected — the
report sections already cover list-shaped and prose-shaped text.

## Totals

- 9 files, 238 lines, 84359 bytes, 34090 characters.
