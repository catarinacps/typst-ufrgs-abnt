#import "@preview/glossarium:0.5.10": make-glossary, gls, glspl, register-glossary
#import "@preview/i-figured:0.2.4"
#import "spacing.typ": *
#import "pages.typ": *
#import "presets.typ" as presets: *
#import "labels.typ": default-labels, make-labels, localize

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
                    supplement: none,
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

// Post-textual parts with lettered primary sections (ABNT NBR 14724:2024,
// 4.2.3.3-4.2.3.4): the state holds the word that precedes the letter
// ("Appendix", "Annex") inside them, and is `none` elsewhere.
#let post-textual = state("typst-ufrgs-abnt-post-textual", none)

// Consecutive capital letters, doubled once the alphabet is exhausted
// (A, ..., Z, AA, BB, ...); lower levels numbered as usual (A.1, A.1.1).
#let post-textual-letter(n) = {
    let k = n - 1
    str.from-unicode(65 + calc.rem(k, 26)) * (calc.quo(k, 26) + 1)
}
#let post-textual-numbering(..nums) = {
    let n = nums.pos()
    (post-textual-letter(n.first()), ..n.slice(1).map(str)).join(".")
}

#let author(surname, first-name, title: none, institution: none) = {
    (surname: surname, first-name: first-name, title: title, institution: institution)
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

    // Overrides for the fixed texts of the document language, e.g.
    // `(contents: [Table of Contents])`; see `labels.typ` for the keys.
    labels: (:),

    date: datetime.today(),

    references: none,

    // Post-textual elements, printed after the references in this order
    // (ABNT NBR 14724:2024, 4.2.3). Each primary section (`=`) in them is one
    // appendix/annex, titled "APPENDIX A — TITLE".
    appendices: none,

    annexes: none,

    // Approval sheet (ABNT NBR 14724:2024, 4.2.1.3), printed after the
    // nominata: `none`, a dictionary `(date: datetime(...) or none,
    // committee: (author(..., institution: [...]), ...))` to typeset it, or
    // content such as `image("approval.pdf")` to place a scanned signed sheet.
    approval: none,

    // Catalog card (ficha catalográfica, ABNT NBR 14724:2024, 4.2.1.1.2), at
    // the top of the nominata page: `none` (at UFRGS the library adds it to the
    // submitted PDF), `auto` to typeset it from the document's data, or
    // content such as `image("ficha.pdf")` to place a card as-is.
    catalog-card: none,

    two-sided: true,

    body,
) = {
    show: make-glossary
    register-glossary(glossary)

    let labels = make-labels(language, labels)

    if approval != none {
        assert(
            type(approval) in (dictionary, content),
            message: "typst-ufrgs-abnt: `approval` must be none, a dictionary (date, committee) "
                + "or content (a scanned sheet), got " + str(type(approval)),
        )
        if type(approval) == dictionary {
            let unknown = approval.keys().filter(k => k not in ("date", "committee"))
            assert(
                unknown.len() == 0,
                message: "typst-ufrgs-abnt: unknown approval keys: " + unknown.join(", "),
            )
            assert(
                type(approval.at("date", default: none)) in (type(none), datetime),
                message: "typst-ufrgs-abnt: `approval.date` must be a datetime or none",
            )
            let committee = approval.at("committee", default: none)
            assert(
                type(committee) == array,
                message: "typst-ufrgs-abnt: `approval.committee` must be an array of author(...) "
                    + "(a single member needs a trailing comma: `(author(...),)`)",
            )
            assert(
                committee.len() > 0,
                message: "typst-ufrgs-abnt: `approval.committee` must list at least one member",
            )
            for member in committee {
                assert(
                    type(member) == dictionary and "surname" in member and "first-name" in member,
                    message: "typst-ufrgs-abnt: committee members must be author(...), got " + repr(member),
                )
            }
        }
    }
    assert(
        catalog-card in (none, auto) or type(catalog-card) == content,
        message: "typst-ufrgs-abnt: `catalog-card` must be none, auto or content "
            + "(e.g. `image(\"ficha.pdf\")`), got " + str(type(catalog-card)),
    )

    let preset-pt = localize(preset, "pt")
    let course-pt = localize(course, "pt")
    let preset = localize(preset, language)
    let course = localize(course, language)

    // the document language decides which is the main title and which abstract comes first
    // (ABNT NBR 14724:2024, 4.2.1.7-4.2.1.8).
    let abstracts = (
        en: (title: title, body: abstract, keywords: keywords),
        pt: (title: titulo, body: resumo, keywords: palavras-chave),
    )
    let other-language = if language == "pt" { "en" } else { "pt" }

    set document(title: abstracts.at(language).title, author: author.first-name)

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
    show heading.where(level: 1): it => context {
        let word = post-textual.get()
        if word != none and it.numbering != none {
            // ABNT NBR 14724:2024, 4.2.3.3-4.2.3.4 and 5.2.3: the word, the
            // letter, a dash and the title, centered.
            set align(center)
            block(sticky: true, strong(upper[
                #word #counter(heading).display(it.numbering) --- #it.body
            ]))
        } else {
            strong(upper(it))
        }
    }
    show heading.where(level: 2): it => strong(it)
    show heading.where(level: 3): it => strong(emph(it))
    show heading.where(level: 4): it => emph(it)

    show heading.where(numbering: none): it => align(center + top, it)

    set outline(indent: 0em)

    set heading(numbering: none, outlined: false, bookmarked: true)

    set par(justify: true, leading: single-spacing, spacing: single-spacing)

    {
        // show heading: it => { it; par(box()); v(-0.25em) }

        cover-page(preset, course, author, date, two-sided)

        title-page(preset, course, author, advisor, co-advisor, date, labels)

        nominata-page(preset, course, card: if catalog-card == auto {
            make-catalog-card(
                author, advisor, co-advisor, abstracts.at(language).keywords,
                preset-pt, course-pt, date, two-sided, labels,
            )
        } else {
            catalog-card
        })

        if approval != none {
            approval-page(approval, author, course, language, labels)
        }

        if acknowledgements != none {
            acknowledgements-page(acknowledgements, labels)
        }

        if epigraph != none {
            epigraph-page(epigraph.quote, epigraph.author)
        }

        // The vernacular abstract first, then the foreign one under its
        // translated title.
        for lang in (language, other-language) {
            let a = abstracts.at(lang)
            abstract-page(
                a.body,
                a.keywords,
                language: lang,
                labels: if lang == language { labels } else { default-labels.at(lang) },
                title: if lang != language { a.title },
            )
        }

        // Lists and the summary are single-spaced, following the INF house
        // style (infufrgs.cls); ABNT NBR 14724, 5.2 would call for 1.5 here.
        set par(leading: single-spacing, spacing: single-spacing)

        context {
            if counter(std-figure.where(kind: image)).final().at(0) > 0 {
                page(i-figured.outline(target-kind: image, title: labels.list-of-figures))
            }

            if counter(std-figure.where(kind: table)).final().at(0) > 0 {
                page(i-figured.outline(target-kind: table, title: labels.list-of-tables))
            }

            if counter(std-figure.where(kind: raw)).final().at(0) > 0 {
                page(i-figured.outline(target-kind: raw, title: labels.list-of-listings))
            }
        }

        glossary-page(glossary, labels)

        // ABNT NBR 6027, 5.1-5.2: section numbers flush left, all titles
        // (post-textual ones included) aligned by the longest number; 6.2:
        // same typographic distinction as the section titles in the text.
        show outline.entry: it => context {
            let lettered(h) = h.level == 1 and post-textual.at(h.location()) != none
            let numbers = query(heading.where(outlined: true))
                .filter(h => h.numbering != none and not lettered(h))
                .map(h => measure(strong(numbering(h.numbering, ..counter(heading).at(h.location())))).width)
            let width = calc.max(0pt, ..numbers) + 0.5em
            // Appendices and annexes: the whole "APPENDIX A — Title" is
            // the title, aligned with the other titles.
            let word = post-textual.at(it.element.location())
            let entry = link(
                it.element.location(),
                if it.level == 1 and word != none and it.element.numbering != none {
                    it.indented(box(width: width), [#word #it.prefix() --- ] + it.inner(), gap: 0pt)
                } else {
                    it.indented(box(width: width, it.prefix()), it.inner(), gap: 0pt)
                },
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

        outline(title: labels.contents)
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
        [#labels.source: #it.body]
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

    show heading.where(level: 1): set heading(supplement: labels.chapter)
    show heading.where(level: 2): set heading(supplement: labels.section)
    show heading.where(level: 3): set heading(supplement: labels.subsection)
    show heading.where(level: 4): set heading(supplement: labels.subsubsection)
    show heading.where(level: 5): set heading(supplement: labels.paragraph)

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
            // The page counter, not the physical page: the cover is not
            // counted. The parity test above stays physical, which matches
            // because the cover takes two pages in two-sided mode.
            [#counter(page).get().first()]
        )
    })

    {
        body
    }

    if references != none {
        // ABNT NBR 6023, 6.3: single spacing, aligned to the left margin,
        // entries separated by a blank single-spaced line.
        set par(justify: false, leading: single-spacing, spacing: double-spacing)

        bibliography(references, style: path("abnt-ufrgs.csl"), title: labels.references)
    }

    let lettered-part(content, word) = {
        post-textual.update(word)
        counter(heading).update(0)

        set heading(numbering: post-textual-numbering)
        show heading.where(level: 1): set heading(supplement: word)
        show std-figure: i-figured.show-figure.with(numbering: post-textual-numbering)

        content
    }

    if appendices != none {
        lettered-part(appendices, labels.appendix)
    }

    if annexes != none {
        lettered-part(annexes, labels.annex)
    }
}
