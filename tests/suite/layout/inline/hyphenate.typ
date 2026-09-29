// Test mid-word breaking.

--- hyphenate paged ---
// Test breaking words in english and greek.
#set par(emergency-break: 0%)
#set page(width: auto)
#grid(
  columns: (50pt, 50pt),
  [Warm welcomes to Typst.],
  text(lang: "el")[διαμερίσματα. \ λατρευτός],
)

--- hyphenate-off-temporarily paged ---
// Test enabling and disabling mid-word breaking.
#set page(width: 110pt)
#set par(emergency-break: 30%)

Welcome to wonderful experiences. \
Welcome to `wonderful` experiences. \
Welcome to [wonderful] experiences. \

// Test that no word is cut when the share is unset.
#set par(emergency-break: none)
Welcome to wonderful experiences. \
Welcome to `wonderful` experiences. \
Welcome to [wonderful] experiences. \

--- hyphenate-between-shape-runs paged ---
// Cut a word between shape runs.
#set page(width: 80pt)
#set par(emergency-break: 30%)
It's a #emph[Tree]beard.

--- hyphenate-shy paged ---
// Test shy hyphens.
#set text(lang: "de")
#set par(emergency-break: 0%)
#grid(
  columns: 2 * (20pt,),
  gutter: 20pt,
  [Barankauf],
  [Bar-?ankauf],
)

--- hyphenate-punctuation paged ---
// This sequence would confuse hypher if we passed trailing / leading
// punctuation instead of just the words. So this tests that we don't
// do that. The test passes if there's just one cut between
// "net" and "works".
#set page(width: 60pt)
#set par(emergency-break: 30%)
#h(6pt) networks, the rest.

--- hyphenate-outside-of-words paged ---
// More tests for cutting non-words.
#set par(emergency-break: 0%)
#block(width: 0pt, "doesn't")
#block(width: 0pt, "(OneNote)")
#block(width: 0pt, "(present)")

#set text(lang: "de")
#block(width: 0pt, "(bzw.)")

--- hyphenate-pt-repeat-hyphen-natural-word-breaking paged ---
// The word breaker naturally breaks arco-da-velha at arco-/-da-velha,
// so we shall repeat the hyphen, even that breaking is not enabled.
#set page(width: 4cm)
#set text(lang: "pt")

Alguma coisa no arco-da-velha é algo que está muito longe.

--- hyphenate-pt-repeat-hyphen-hyphenate-true paged ---
#set page(width: 4cm)
#set text(lang: "pt")
#set par(emergency-break: 0%)

Alguma coisa no arco-da-velha é algo que está muito longe.

--- hyphenate-pt-repeat-hyphen-hyphenate-true-with-emphasis paged ---
#set page(width: 4cm)
#set text(lang: "pt")
#set par(emergency-break: 0%)

Alguma coisa no _arco-da-velha_ é algo que está muito longe.

--- hyphenate-pt-no-repeat-hyphen paged ---
#set page(width: 4cm)
#set text(lang: "pt")
#set par(emergency-break: 0%)

Um médico otorrinolaringologista cuida da garganta do paciente.

--- hyphenate-pt-dash-emphasis paged ---
// If the hyphen is followed by a space we shall not repeat the hyphen
// at the next line
#set page(width: 4cm)
#set text(lang: "pt")
#set par(emergency-break: 0%)

Quebabe é a -melhor- comida que existe.

--- hyphenate-es-repeat-hyphen paged ---
#set page(width: 6cm)
#set text(lang: "es")
#set par(emergency-break: 0%)

Lo que entendemos por nivel léxico-semántico, en cuanto su sentido más
gramatical: es aquel que estudia el origen y forma de las palabras de
un idioma.

--- hyphenate-es-capitalized-names paged ---
// If the hyphen is followed by a capitalized word we shall not repeat
//  the hyphen at the next line
#set page(width: 6.2cm)
#set text(lang: "es")
#set par(emergency-break: 0%)

Tras el estallido de la contienda Ruiz-Giménez fue detenido junto a sus
dos hermanos y puesto bajo custodia por las autoridades republicanas, con
el objetivo de protegerle de las patrullas de milicianos.

--- hyphenate-repeat-style paged ---
// Ensure that a repeated hard hyphen keeps its styles.
#set page(width: 2cm)
#set text(lang: "es")
Hello-#text(red)[world]

--- costs-widow-orphan paged ---
#set page(height: 60pt)

#let sample = lorem(12)

#sample
#pagebreak()
#set text(costs: (widow: 0%, orphan: 0%))
#sample

--- costs-runt-avoid paged ---
#set par(justify: true)

#let sample = [please avoid runts in this text.]

#sample
#pagebreak()
#set text(costs: (runt: 10000%))
#sample

--- costs-runt-allow paged ---
#set par(justify: true)
#set text(size: 6pt)

#let sample = [a a a a a a a a a a a a a a a a a a a a a a a a a]

#sample
#pagebreak()
#set text(costs: (runt: 0%))
#sample

--- costs-hyphenation-avoid paged ---
// The cut cost is an internal constant, so the only way to avoid a mid-word
// cut is to not make the word eligible for one.
#set par(justify: true)

#let sample = [we've increased the threshold for cutting words apart.]

#set par(emergency-break: 30%)
#sample
#pagebreak()
#set par(emergency-break: none)
#sample

--- costs-invalid-type eval ---
// Error: 18-30 expected ratio, found auto
#set text(costs: (runt: auto))

--- costs-invalid-key eval ---
// Error: 18-45 unexpected key "invalid-key", valid keys are "runt", "widow", and "orphan"
#set text(costs: (runt: 1%, invalid-key: 3%))

--- costs-access paged empty ---
#set text(costs: (runt: 2%))
#set text(costs: (widow: 3%))
#context test(text.costs, (runt: 2%, widow: 3%, orphan: 100%))

--- issue-hyphenate-after-tag paged ---
// Ensure that an invisible tag does not prevent a mid-word cut.
#set page(width: 50pt)
#set par(emergency-break: 30%)
#show "Tree": emph
#show emph: set text(red)
#show emph: it => it + metadata(none)
Treebeard
