#import "@preview/glossarium:0.5.10": print-glossary
#import "spacing.typ": *

#let blank-page(labels) = page(align(center + bottom, emph(labels.blank-page)))

#let cover-page(institution, course, author, advisor, co-advisor, date, labels) = {
    page(align(center, context {
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

        align(right, block(width: 50%, {
            set align(left)
            set text(size: 10pt)

            (labels.bachelors-nature)(course.title, course.name)
            blank-line-spacing
            [#labels.advisor: #advisor.title #advisor.first-name #advisor.surname]

            if co-advisor != none {
                linebreak()
                [#labels.co-advisor: #co-advisor.title #co-advisor.first-name #co-advisor.surname]
            }
        }))

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
