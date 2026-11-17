#import "@preview/glossarium:0.5.10": print-glossary
#import "@preview/datify:1.3.0": custom-date-format
#import "spacing.typ": *

// The nature of the work, aligned from the middle of the text area to the
// right margin (ABNT NBR 14724:2024, 5.2); `body` follows it in the same block.
#let nature-block(course, labels, body: none) = align(right, block(width: 50%, {
    set align(left)
    set text(size: 10pt)

    (labels.bachelors-nature)(course.title, course.name)
    body
}))

// Layout shared by the cover and the title page; `middle` (if any) goes
// below the title. `start-counting` restarts the page counter at this page; the
// update has to be inside the page, or it lands on the page before it.
#let cover-layout(institution, course, author, date, middle: none, start-counting: false) = {
    page(align(center, context {
        if start-counting {
            counter(page).update(1)
        }

        set text(hyphenate: false)
        set par(justify: false)
        set align(top)

        upper()[
            #institution.name\
            #course.department\
            #course.program
        ]

        v(2cm)

        upper()[#author.first-name #author.surname]

        set align(horizon)

        text(size: 14pt, strong(document.title))

        if middle != none {
            v(1cm)
            middle
        }

        set align(bottom)

        upper()[
            #institution.location\
            #date.display("[year]")
        ]
    }))
}

// The cover (capa, ABNT NBR 14724:2024, 4.1.1). It is part of the external
// part of the work and is not counted (5.3); in two-sided mode its back is an
// empty page, so the title page still starts on a recto.
#let cover-page(institution, course, author, date, two-sided) = {
    cover-layout(institution, course, author, date)

    if two-sided {
        page[]
    }
}

// The title page (folha de rosto, ABNT NBR 14724:2024, 4.2.1.1.1); page
// counting starts here (5.3).
#let title-page(institution, course, author, advisor, co-advisor, date, labels) = {
    cover-layout(institution, course, author, date, start-counting: true, middle: nature-block(course, labels, body: {
        blank-line-spacing
        [#labels.advisor: #advisor.title #advisor.first-name #advisor.surname]

        if co-advisor != none {
            linebreak()
            [#labels.co-advisor: #co-advisor.title #co-advisor.first-name #co-advisor.surname]
        }
    }))
}

#let acknowledgements-page(acknowledgements, labels) = page[
    = #labels.acknowledgements

    #set par(first-line-indent: 3em, leading: normal-spacing, spacing: normal-spacing)

    #acknowledgements
]

#let epigraph-page(quote, author) = page(align(right + bottom)[
    _#quote _\
    -- #author
])

// The nominata, at the bottom of the back of the title page. The top of the
// page holds the catalog card (`card`), if any; without one it stays free for
// the card the UFRGS library stamps onto the submitted PDF.
#let nominata-page(institution, course, card: none) = page({
    if card != none {
        align(center, card)
    }

    v(1fr)

    upper(institution.name)
    linebreak()
    (institution.nominata + course.nominata).map(it => it.join([: ])).join(linebreak())
})

// The catalog card (ficha catalográfica, CIP; ABNT NBR 14724:2024, 4.2.1.1.2),
// laid out like the `\iiu@cipwindow` box of infufrgs.cls and the cards the
// UFRGS library issues. Institution and unit names are always the Portuguese
// ones (`institution-pt`, `course-pt`), as on the library's cards. The page
// count is the last page number, in sheets ("f.") one-sided or pages ("p.")
// two-sided; "il." is added when the document has figures.
#let make-catalog-card(
    author, advisor, co-advisor, keywords, institution-pt, course-pt, date, two-sided, labels,
) = context {
    let name(person) = [#person.first-name #person.surname]
    let entry(person) = [#person.surname, #person.first-name]
    let year = date.display("[year]")
    let pages = counter(page).final().first()
    let illustrated = query(figure.where(kind: image)).len() > 0

    let advisors = [#labels.advisor: #name(advisor)]
    if co-advisor != none {
        advisors += [; #labels.co-advisor: #name(co-advisor)]
    }

    let added = (advisor, co-advisor).filter(it => it != none).map(entry)
    added.push(labels.catalog-card-title)
    let roman = ("I", "II", "III", "IV", "V", "VI")

    strong(upper(labels.catalog-card))
    v(1em)

    block(width: 120mm, stroke: 0.5pt, inset: (x: 5mm, y: 4mm), {
        set align(left)
        set par(
            justify: true,
            leading: single-spacing,
            spacing: 0.6em,
            first-line-indent: (amount: 1.5em, all: false),
        )

        entry(author)
        parbreak()
        [#document.title / #name(author). -- #institution-pt.city, #year.]
        parbreak()
        [#pages #if two-sided [p.] else [f.]#if illustrated [: il. color.]]
        parbreak()
        [#labels.catalog-card-nature -- #institution-pt.name. #course-pt.department.
            #course-pt.program, #institution-pt.city, BR--#institution-pt.state, #year.
            #advisors.]
        parbreak()
        (
            keywords.enumerate().map(((i, k)) => [#(i + 1). #k.])
            + added.enumerate().map(((i, e)) => [#roman.at(i). #e.])
        ).join(" ")
    })
}

// The approval sheet (folha de aprovação, ABNT NBR 14724:2024, 4.2.1.3), with
// no title (5.2.4). `approval` is either content (a scanned signed sheet,
// placed full-page) or a dictionary with the approval `date` (`none` leaves a
// line to fill in by hand) and the examining `committee` (`author(...)`s).
#let approval-page(approval, author, course, language, labels) = {
    if type(approval) == content {
        return page(margin: 0pt, {
            set image(width: 100%, height: 100%, fit: "contain")
            align(center + horizon, approval)
        })
    }

    page(context {
        set text(hyphenate: false)
        set par(justify: false)
        set align(center)

        upper[#author.first-name #author.surname]

        v(2cm)

        text(size: 14pt, strong(document.title))

        v(1cm)

        nature-block(course, labels)

        v(1cm)

        let date = approval.at("date", default: none)
        [#labels.approved-on: ]
        if date == none {
            box(width: 4cm, stroke: (bottom: 0.5pt))
        } else {
            custom-date-format(date, pattern: "long", lang: language)
        }

        v(1fr)

        strong(upper(labels.examining-committee))

        for member in approval.committee {
            block(breakable: false, above: 1.5cm, {
                line(length: 9cm, stroke: 0.5pt)
                (member.at("title", default: none), member.first-name, member.surname)
                    .filter(it => it != none)
                    .join(" ")
                if member.at("institution", default: none) != none {
                    linebreak()
                    member.institution
                }
            })
        }

        v(1fr)
    })
}

// An abstract with its keywords, typeset in `language`; `title` is printed
// above it (the translated title, for the abstract in the foreign language).
#let abstract-page(abstract, keywords, language: "en", labels: none, title: none) = page[
    #set text(lang: language)

    #if title != none {
        align(center + top, strong(title))
    }

    = #labels.abstract

    #par(leading: normal-spacing, abstract)

    #v(1.5cm)

    #labels.keywords: #keywords.join("; ")\.
]

#let print-abbreviation(entry) = {
    let short = entry.at("short")
    let long = entry.at("long")

    box(width: 1fr, short); box(width: 4fr, long);
}

#let abbreviations-page(terms, labels) = page[
    = #labels.list-of-abbreviations

    #{
        set strong(delta: 0)
        print-glossary(terms, show-all: true, disable-back-references: true, user-print-title: print-abbreviation)
    }
]

// Plain text of a string or content, for sorting.
#let plain-text(it) = {
    if type(it) == str {
        it
    } else if it.has("text") {
        it.text
    } else if it.has("children") {
        it.children.map(plain-text).join()
    } else if it.has("body") {
        plain-text(it.body)
    } else if it == [ ] {
        " "
    } else {
        ""
    }
}

// Alphabetical sort key: case- and accent-insensitive, so "árvore" sorts
// between "Abelha" and "beta".
#let alphabetical-key(it) = lower(plain-text(it).normalize(form: "nfd").replace(regex("\\p{M}"), ""))

// The glossary (ABNT NBR 14724:2024, 4.2.3.2): a centered, unnumbered title
// (5.2.3) listed in the summary, and one paragraph per term, "Term: definition"
// with no hanging indent, spaced like the references (NBR 6023, 6.3).
#let glossary-section(terms, labels) = {
    let sort-keys = terms.map(t => (t.key, t.at("sort", default: alphabetical-key(t.short)))).to-dict()

    heading(numbering: none, outlined: true, labels.glossary)

    // glossarium wraps each entry in a figure; keep them in the text flow and
    // flush left, out of the template's figure placement and centering.
    set figure(placement: none)
    show figure.where(kind: "glossarium_entry"): it => align(start, it.body)

    set par(justify: false, leading: single-spacing, spacing: double-spacing, first-line-indent: 0pt)
    print-glossary(
        terms,
        show-all: true,
        disable-back-references: true,
        entry-sortkey: e => sort-keys.at(e.key),
        // glossarium's default entry has a hanging indent; print our own.
        user-print-gloss: (e, ..args) => {
            strong(e.short)
            let description = e.at("description", default: none)
            if description not in (none, "", []) [: #description]
        },
    )
}
