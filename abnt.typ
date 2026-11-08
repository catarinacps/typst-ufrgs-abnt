#import "@preview/glossarium:0.5.10": make-glossary, gls, glspl, register-glossary
#import "@preview/i-figured:0.2.4"
#import "spacing.typ": *
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

#let epigraph(quote, author) = {
    (quote: quote, author: author)
}

#let abnt(
    title: [The Title],

    titulo: [O Título],

    author: author("Author", "The"),

    advisor: author("Advisor", "The", title: "Prof. Dr."),

    co-advisor: none,

    preset: ufrgs,

    course: ufrgs.courses.cic,

    keywords: ("work's", "keywords"),

    palavras-chave: ("palavras", "chave", "desse", "trabalho"),

    acknowledgements: none,

    epigraph: none,

    abstract: [
        The work's abstract.
    ],

    resumo: [
        O resumo do trabalho.
    ],

    glossary: (
        (key: "ABNT", short: "ABNT", long: "Associação Brasileira de Normas Técnicas"),
        (key: "SBC", short: "SBC", long: "Sociedade Brasileira de Computação")
    ),

    language: "en",

    date: datetime.today(),

    references: none,

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
            (left: 3cm, top: 3cm, right: 2cm, bottom: 2cm)
        } ,
        header-ascent: 1cm,
        footer-descent: 1cm,
    )

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
        section-spacing
        it
        section-spacing
    }

    show heading.where(level: 1): it => strong(upper(it))
    show heading.where(level: 2): it => strong(it)
    show heading.where(level: 4): it => emph(it)

    show heading.where(numbering: none): it => align(center + top, it)

    set outline(indent: 0em)

    set heading(numbering: none, outlined: false, bookmarked: true)

    set par(justify: true, leading: single-spacing, spacing: single-spacing)

    {
        // show heading: it => { it; par(box()); v(-0.25em) }

        cover-page(preset, course, author, advisor, co-advisor, date)

        blank-page()

        nominata-page(preset, course)

        if acknowledgements != none {
            acknowledgements-page(acknowledgements)
        }

        if epigraph != none {
            epigraph-page(epigraph.quote, epigraph.author)
        }

        abstract-page(abstract, keywords)

        resumo-page(resumo, palavras-chave, title: titulo)

        show outline.entry: set text(bottom-edge: "descender")

        context {
            if counter(std-figure.where(kind: image)).final().at(0) > 0 {
                page(i-figured.outline(target-kind: image, title: [List of Figures]))
            }

            if counter(std-figure.where(kind: table)).final().at(0) > 0 {
                page(i-figured.outline(target-kind: table, title: [List of Tables]))
            }

            if counter(std-figure.where(kind: raw)).final().at(0) > 0 {
                page(i-figured.outline(target-kind: raw, title: [List of Listings]))
            }
        }

        glossary-page(glossary)

        show outline.entry.where(level: 1): it => strong(upper(it))
        show outline.entry.where(level: 2): it => strong(it)
        show outline.entry.where(level: 4): it => emph(it)

        outline(title: [Summary])
    }

    show heading.where(level: 1): it => pagebreak(weak: true) + it
    // show heading: it => { it; par(box()); v(-0.75em) }

    set par(first-line-indent: (amount: 1.25cm, all: true), leading: normal-spacing, spacing: normal-spacing)

    show heading: i-figured.reset-counters
    show std-figure: i-figured.show-figure

    set std-figure.caption(
        position: top,
        separator: [ -- ]
    )
    set std-figure(
        placement: auto,
        numbering: "1.1",
        gap: 0.5em
    )

    show std-figure.caption: set text(size: 10pt)

    show std-figure.caption.where(position: bottom): it => {
        set align(start)
        set par(first-line-indent: 0pt)
        [#it.supplement: #it.body]
    }

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

    set table(
        stroke: (x, y) => (
            top: if y == 0 {1pt} else if y == 1 {0.75pt} else {0pt},
            bottom: 1pt
        ),
        align: horizon,
        inset: 4pt,
    )

    show table.cell: set text(size: 10pt)

    show std-figure.where(kind: raw): set par(leading: single-spacing)

    set heading(numbering: "1.1", outlined: true)

    show heading.where(level: 1): set heading(supplement: [Chapter])
    show heading.where(level: 3): set heading(supplement: [Subsection])
    show heading.where(level: 4): set heading(supplement: [Subsubsection])
    show heading.where(level: 5): set heading(supplement: [Subsubsubsection])

    set page(header: context {
        align(
            if calc.odd(here().page()) or not two-sided {
                right
            } else {
                left
            },
            pad(x: -0.5cm)[#here().page()]
        )
    })

    {
        body
    }

    set par(justify: true, leading: single-spacing, spacing: single-spacing)

    if references != none {
        bibliography(references, style: path("abnt-ufrgs.csl"), title: [References])
    }
}
