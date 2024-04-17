#import "@preview/typst-abnt:0.1.0": abnt, presets
#import presets: ufrgs

#show: abnt.with(
    abstract: lorem(200),
    preset: ufrgs,
    course: ufrgs.courses.cic,
    glossary: (
        (key: "abnt", short: "ABNT", long: "Associação Brasileira de Normas Técnicas"),
        (key: "sbc", short: "SBC", long: "Sociedade Brasileira de Computação")
    ),
    references: "refs.bib"
)

= Hey

#lorem(200)

== Testing

Stuff! which is. #lorem(100)

Very cool! @abnt e também @sbc. Cite Einstein's @einsteinNew1955.

= Another Chapter

#lorem(20)

#figure(
    table(
        columns: 4,
        [t], [1], [2], [3],
        [y], [0.3s], [0.4s], [0.8s],
    ),
    caption: [Timing results.],
    source: [Some source.]
) <table>

Can I cite the @tbl:table? I can!

== Section

#lorem(200)

== Oy

#lorem(200)
