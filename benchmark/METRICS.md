# Emergency-break benchmark metrics

Measurements for the `plain` / `cut30` / `cut90` render matrix produced by
`benchmark/scripts/render.sh`. Raw timings and corpus sizes live in
`benchmark/renders/MANIFEST.md`; this file records how to compare the renders
and what the comparison shows.

Commit under test: `7f18cb9a602f3cdebc3f72f5908ce3b715365ed4`
("fix(layout): cut Latin words in Thai paragraphs"), binary
`target/debug/typst`, `typst 0.15.1 (c6f1fa17)`. 54 renders.

## Do not compare PDF checksums

A PDF checksum cannot tell you whether two layouts differ. Typst stamps
`CreationDate`, `ModDate` and a timestamp-derived `/ID` into every file, so two
renders of identical content still hash differently. In a superseded run all 54
PDFs had 54 distinct MD5 sums while the page content was unchanged; the only
textual difference between two such files was the metadata block.

Timestamp fields are fixed width, so **file size does not drift from them**. Size
equality between two renders is meaningful evidence of layout equality; checksum
inequality is not evidence of layout difference.

## What to compare

| Signal | Command | Meaning |
| --- | --- | --- |
| PDF bytes | `wc -c < <pdf>` | Equal size ⇒ layout unchanged |
| Soft hyphen count | `pdftotext -bbox <pdf> - \| grep -o $'­' \| wc -l` | Count of emergency breaks actually taken |
| Word boxes | `pdftotext -bbox <pdf> -` | Glyph positions, metadata-free |
| Raster | `pdftoppm -png -r 150 -f N -l N <pdf> <out>` | Visual confirmation |

## Results

`plain` takes zero emergency breaks in every corpus and measure, as expected.
Breaks appear only in corpora containing Latin runs, and only where the measure
is tight enough for a Latin word to exceed the threshold.

| Measure | Corpus | Latin runs | plain B | cut30 B | cut90 B | plain breaks | cut30 breaks | cut90 breaks |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `a4` | fixture-cluster-linebreak | 0 | 51919 | 51919 | 51919 | 0 | 0 | 0 |
| `a4` | fixture-par-distributed | 3 | 75916 | 75916 | 75916 | 0 | 0 | 0 |
| `a4` | fixture-word-boundaries | 0 | 42981 | 42981 | 42981 | 0 | 0 | 0 |
| `a4` | goat-report-analysis | 288 | 153699 | 153425 | 153699 | 0 | 1 | 0 |
| `a4` | goat-report-intro | 19 | 112466 | 112545 | 112466 | 0 | 2 | 0 |
| `a4` | goat-report-methodology | 228 | 172304 | 172304 | 172304 | 0 | 0 | 0 |
| `a4` | goat-report-problem | 0 | 62960 | 62960 | 62960 | 0 | 0 | 0 |
| `a4` | goat-report-related-works | 131 | 156282 | 156362 | 156282 | 0 | 1 | 0 |
| `a4` | goat-report-scope | 19 | 88398 | 88398 | 88398 | 0 | 0 | 0 |
| `narrow` | fixture-cluster-linebreak | 0 | 52017 | 52017 | 52017 | 0 | 0 | 0 |
| `narrow` | fixture-par-distributed | 3 | 76137 | 76137 | 76137 | 0 | 0 | 0 |
| `narrow` | fixture-word-boundaries | 0 | 43071 | 43071 | 43071 | 0 | 0 | 0 |
| `narrow` | goat-report-analysis | 288 | 183987 | 186884 | 185200 | 0 | 41 | 13 |
| `narrow` | goat-report-intro | 19 | 121969 | 122102 | 122095 | 0 | 2 | 2 |
| `narrow` | goat-report-methodology | 228 | 202045 | 205151 | 203087 | 0 | 38 | 14 |
| `narrow` | goat-report-problem | 0 | 63173 | 63173 | 63173 | 0 | 0 | 0 |
| `narrow` | goat-report-related-works | 131 | 180118 | 181508 | 180663 | 0 | 23 | 9 |
| `narrow` | goat-report-scope | 19 | 91262 | 91373 | 91337 | 0 | 2 | 1 |

"Latin runs" counts `[A-Za-z]{4,}` matches in the corpus source.

`cut30` breaks more often than `cut90` because `emergency-break` is a
threshold, not a budget: `30%` lets any word wider than 30% of the measure be
cut, `90%` only words wider than 90%. At the `a4` measure of 146.5mm almost
nothing clears the bar; at the `narrow` measure of 32mm the technical terms do.

The three `fixture-*` corpora and `goat-report-problem` are unchanged across
every variant. They hold 0, 3, 0 and 0 Latin runs respectively, so there is
nothing for a Latin-word cut to act on. That is the expected result, not a
failure of the fix.

## Effect on pagination

`narrow` / `goat-report-methodology`, 14 pages in all three variants, compared by
rasterising each page at 60 dpi and hashing:

| Pages | plain vs cut30 | plain vs cut90 | cut30 vs cut90 |
| --- | --- | --- | --- |
| 1–9 | identical | identical | identical |
| 10–14 | differ | differ | differ |

Emergency breaking changes where lines fall on the last five pages but does not
change the page count. `narrow` / `goat-report-intro`,
`narrow` / `goat-report-scope` and the three `a4` corpora that differ have
identical page counts for the same reason.

Page 10 of `narrow` / `goat-report-methodology`, read directly:

- `plain` — every Latin term stays whole. Justification stretches to compensate,
  so inter-word gaps are wide and the column is airy. `(target` and `modules):`
  wrap across two lines with a large gap; `FLORES-200` sits whole on its line.
- `cut30` — `(target mod-` / `ules):`, `(opti-` / `mizer)` and `FLO-` /
  `RES-200` are cut mid-word. The column packs visibly more text per line and
  the justification gaps largely disappear.
- `cut90` — intermediate. `learn-` / `ing` is cut; `modules`, `optimizer` and
  `FLORES-200` are left whole. Gaps remain wide, slightly tighter than `plain`.

## Conclusion

`emergency-break` demonstrably changes Thai line breaking for Latin technical
terms inside Thai paragraphs. The size of the effect is small on the `a4`
measure (1–2 cuts across a whole document) and clear on the `narrow` measure
(38 cuts in `goat-report-methodology`, 41 in `goat-report-analysis`). The cut is
visible on the page, not merely a byte-count difference: justified Thai text
with uncut Latin terms sets noticeably looser lines than the same text with a
30% emergency-break threshold.
