#import "@preview/glossarium:0.5.4": make-glossary, gls, glspl, register-glossary
#import "@preview/i-figured:0.2.4"
#import "pages.typ": *
#import "presets.typ" as presets: *

#let std-figure = figure

#let figure(body,
    kind: auto,
    placement: none,
    caption: none,
    supplement: auto,
    numbering: "1.1",
    gap: 0.5em,
    outlined: true,
    source: none) = {
        let inner = std-figure(
            body,
            placement: placement,
            caption: caption,
            kind: kind,
            supplement: supplement,
            numbering: numbering,
            gap: gap,
            outlined: outlined)

        if source != none {
            std-figure(
                box(std-figure(
                    inner.body,
                    kind: "nested",
                    supplement: [Source],
                    numbering: none,
                    caption: std-figure.caption(source, position: bottom),
                    gap: gap
                )),
                caption: std-figure.caption(inner.caption.body, position: top),
                kind: inner.kind,
                placement: placement,
                numbering: numbering,
                outlined: outlined,
                supplement: supplement,
                gap: gap
            )
        } else { inner }
    }

#let author(surname, first-name, title: none) = {
    (surname: surname, first-name: first-name, title: title)
}

#let abnt(
    title: "The Title",

    author: author("Author", "The"),

    advisor: author("Advisor", "The", title: "Prof. Dr."),

    co-advisor: none,

    preset: ufrgs,

    course: ufrgs.courses.cic,

    keywords: ("work's", "keywords"),

    abstract: [
        The work's abstract.
    ],

    toc-title: "Summary",

    glossary: (
        (key: "ABNT", short: "ABNT", long: "Associação Brasileira de Normas Técnicas"),
        (key: "SBC", short: "SBC", long: "Sociedade Brasileira de Computação")
    ),

    language: "en",

    date: datetime.today(),

    references: "refs.bib",

    two-sided: true,

    body,
) = {
    show: make-glossary
    register-glossary(glossary)

    set document(title: title, author: author.first-name)

    set page(
        paper: "a4",
        margin: if two-sided {
            (inside: 3cm, outside: 2cm, top: 3cm, bottom: 2cm)
        } else {
            (right: 3cm, left: 3cm, top: 3cm, bottom: 2cm)
        } ,
        header-ascent: 100% - 2cm,
        footer-descent: 100% - 2cm,
    )

    let single-spacing = 0.65em * 1.75

    set text(
        font: "STIX Two Text",
        size: 12pt,
        weight: "regular",
        lang: language,
        top-edge: 0.7em,
        bottom-edge: -0.3em,
    )

    show heading: set text(size: 12pt, weight: "regular")

    

    show heading: it => if it.level < 4 {
        v(3em, weak: true)
        it
        v(2.5em, weak: true)
    }

    show heading.where(level: 1): it => strong(upper(it))
    show heading.where(level: 2): it => upper(it)
    show heading.where(level: 3): it => strong(it)
    show heading.where(level: 5): it => emph(it)

    show heading.where(numbering: none): it => align(center + top, it)

    set outline(indent: 0em)

    set heading(numbering: none, outlined: false, bookmarked: true)

    set par(justify: true, leading: 0.25em, spacing: 0.25em)

    {
        show heading: it => { it; par(box()); v(-0.25em) }

        cover-page(preset, course, author, advisor, date)

        blank-page()

        nominata-page(preset, course)

        abstract-page(abstract, keywords)

        show outline.entry: set text(top-edge: "cap-height", bottom-edge: "baseline")
        show outline: set par(leading: 0.65em)

        page(i-figured.outline(target-kind: image, title: [Index of Figures]))
        page(i-figured.outline(target-kind: table, title: [Index of Tables]))
        page(i-figured.outline(target-kind: raw, title: [Index of Listings]))

        glossary-page(glossary)

        show outline.entry.where(level: 1): it => strong(upper(it))
        show outline.entry.where(level: 2): it => upper(it)
        show outline.entry.where(level: 3): it => strong(it)
        show outline.entry.where(level: 5): it => emph(it)

        outline(title: toc-title)
    }

    show heading.where(level: 1): it => pagebreak(weak: true) + it
    show heading: it => { it; par(box()); v(-0.75em) }

    set par(first-line-indent: 3em, leading: 0.75em, spacing: 0.75em)

    show heading: i-figured.reset-counters
    show std-figure: i-figured.show-figure

    set std-figure.caption(
        position: top,
        separator: [ -- ]
    )
    set std-figure(
        placement: auto,
        numbering: "1.1",
        gap: 0.5em)

    show std-figure.caption: set text(size: 10pt)

    show std-figure.caption.where(position: bottom): it => [
        #v(0.1em)
        #it.supplement: #it.body
    ]

    set enum(
        indent: 1.5em,
        body-indent: 0.4em,
        full: true,
        numbering: "1.1")

    set list(
        indent: 1.5em,
        body-indent: 0.4em,
        marker: ([•], [--], [◦]))

    show math.equation: set block(spacing: 1em)
    set math.equation(
        block: true,
        numbering: "(1)")

    set heading(numbering: "1.1", outlined: true)

    set page(header: context {
        align(if calc.odd(here().page()) or not two-sided {
            right
        } else {
            left
        },
            [#here().page()])
    })

    {
        body
    }

    bibliography(references, style: "associacao-brasileira-de-normas-tecnicas")
}
