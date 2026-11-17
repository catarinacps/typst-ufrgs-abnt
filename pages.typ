#import "@preview/glossarium:0.5.10": print-glossary
#import "@preview/datify:1.3.0": custom-date-format
#import "spacing.typ": *

#let blank-page(labels) = page(align(center + bottom, emph(labels.blank-page)))

// The nature of the work, aligned from the middle of the text area to the
// right margin (ABNT NBR 14724:2024, 5.2); `body` follows it in the same block.
#let nature-block(course, labels, body: none) = align(right, block(width: 50%, {
    set align(left)
    set text(size: 10pt)

    (labels.bachelors-nature)(course.title, course.name)
    body
}))

#let cover-page(institution, course, author, advisor, co-advisor, date, labels) = {
    page(align(center, context {
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

        v(1cm)

        nature-block(course, labels, body: {
            blank-line-spacing
            [#labels.advisor: #advisor.title #advisor.first-name #advisor.surname]

            if co-advisor != none {
                linebreak()
                [#labels.co-advisor: #co-advisor.title #co-advisor.first-name #co-advisor.surname]
            }
        })

        set align(bottom)

        upper()[
            #institution.location\
            #date.display("[year]")
        ]
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

#let nominata-page(institution, course) = page(align(bottom + left)[
    #upper(institution.name)\
    #(institution.nominata + course.nominata).map(it => it.join([: ])).join(linebreak())
])

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

#let print-glossary-title(entry) = {
    let short = entry.at("short")
    let long = entry.at("long")

    box(width: 1fr, short); box(width: 4fr, long);
}

#let glossary-page(terms, labels) = page[
    = #labels.list-of-abbreviations

    #{
        set strong(delta: 0)
        print-glossary(terms, show-all: true, disable-back-references: true, user-print-title: print-glossary-title)
    }
]
