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

    // ABNT NBR 14724, 5.2.2: titles separated from the surrounding text by a
    // blank 1.5-spaced line.
    show heading: set block(above: section-spacing, below: section-spacing)

    // ABNT NBR 6024, 4.1 j: gradual typographic distinction from the primary
    // to the quinary section, identical in the summary (NBR 6027, 6.2).
    show heading.where(level: 1): it => strong(upper(it))
    show heading.where(level: 2): it => strong(it)
    show heading.where(level: 3): it => strong(emph(it))
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

        // Lists and the summary are single-spaced, following the INF house
        // style (infufrgs.cls); ABNT NBR 14724, 5.2 would call for 1.5 here.
        set par(leading: single-spacing, spacing: single-spacing)

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

        // ABNT NBR 6027, 5.1-5.2: section numbers flush left, all titles
        // (post-textual ones included) aligned by the longest number; 6.2:
        // same typographic distinction as the section titles in the text.
        show outline.entry: it => context {
            let numbers = query(heading.where(outlined: true))
                .filter(h => h.numbering != none)
                .map(h => measure(strong(numbering(h.numbering, ..counter(heading).at(h.location())))).width)
            let width = calc.max(0pt, ..numbers) + 0.5em
            let entry = link(
                it.element.location(),
                it.indented(box(width: width, it.prefix()), it.inner(), gap: 0pt),
            )
            if it.level == 1 { strong(upper(entry)) }
            else if it.level == 2 { strong(entry) }
            else if it.level == 3 { strong(emph(entry)) }
            else if it.level == 4 { emph(entry) }
            else { entry }
        }
        // One blank (single) line before primary sections (not required by
        // ABNT; eases reading the summary's structure).
        show outline.entry.where(level: 1): set block(above: double-spacing)

        // ABNT NBR 6027, 4.1 b: the summary starts on a recto page.
        if two-sided { pagebreak(to: "odd", weak: true) }

        outline(title: [Summary])
    }

    // ABNT NBR 14724, 5.2.2: primary sections start on a new page, on a recto
    // (odd) page when printed on both sides.
    show heading.where(level: 1): it => pagebreak(weak: true, to: if two-sided { "odd" }) + it
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

    // ABNT NBR 14724, 5.1-5.2: titles, sources and legends of illustrations
    // and tables in a smaller font and single spacing.
    show std-figure.caption: set text(size: 10pt)
    show std-figure.caption: set par(leading: single-spacing, spacing: single-spacing)

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

    // ABNT NBR 10520:2023, 7.1.1: direct quotations longer than three lines
    // indented 4cm from the left margin, smaller font, single spacing, no
    // quotation marks. Set apart from the text by a blank 1.5-spaced line.
    show quote.where(block: true): it => block(
        inset: (left: 4cm),
        above: section-spacing,
        below: section-spacing,
        {
            set text(size: 10pt)
            set par(first-line-indent: 0pt, leading: single-spacing, spacing: single-spacing)
            it.body
            if it.attribution != none [ #it.attribution]
        },
    )

    // Footnotes (ABNT NBR 10520:2023, 8): smaller font, single spacing, no blank
    // space between notes, continuation lines aligned under the first letter of
    // the note so the number stands out; numbering restarts at each chapter.
    // ABNT NBR 14724, 5.2.1: separated from the text by a 5cm rule.
    set footnote.entry(indent: 0em, gap: single-spacing, separator: pad(bottom: 0.3em, line(length: 5cm, stroke: 0.5pt)))
    show footnote.entry: it => {
        let loc = it.note.location()
        set text(size: 10pt)
        set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-spacing, justify: true)
        grid(
            columns: (auto, 1fr),
            column-gutter: 0.5em,
            link(loc, super(counter(footnote).display(at: loc, it.note.numbering))),
            it.note.body,
        )
    }
    show heading.where(level: 1): it => counter(footnote).update(0) + it

    set heading(numbering: "1.1", outlined: true)

    show heading.where(level: 1): set heading(supplement: [Chapter])
    show heading.where(level: 3): set heading(supplement: [Subsection])
    show heading.where(level: 4): set heading(supplement: [Subsubsection])
    show heading.where(level: 5): set heading(supplement: [Paragraph])

    // ABNT NBR 14724, 5.3: top outer corner, 2cm from the top edge, the last
    // digit 2cm from the side edge (i.e. at the outer margin), smaller font.
    set page(header: context {
        set text(size: 10pt)
        align(
            if calc.odd(here().page()) or not two-sided {
                right
            } else {
                left
            },
            [#here().page()]
        )
    })

    {
        body
    }

    // ABNT NBR 6023, 6.3: single spacing, aligned to the left margin, entries
    // separated by a blank single-spaced line.
    set par(justify: false, leading: single-spacing, spacing: double-spacing)

    if references != none {
        bibliography(references, style: path("abnt-ufrgs.csl"), title: [References])
    }
}
