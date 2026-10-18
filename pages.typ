#import "@preview/glossarium:0.5.10": print-glossary
#import "presets.typ": bachelors
#import "spacing.typ": *

#let blank-page() = page(align(center + bottom)[_Page intentionally left blank._])

#let cover-page(institution, course, author, advisor, co-advisor, date) = {
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

            bachelors(course.title, course.name)
            blank-line-spacing
            [Advisor: #advisor.title #advisor.first-name #advisor.surname]

            if co-advisor != none {
                linebreak()
                [Co-advisor: #co-advisor.title #co-advisor.first-name #co-advisor.surname]
            }
        }))

        set align(bottom)

        upper()[
            #institution.location\
            #date.display("[year]")
        ]
    }))
}

#let acknowledgements-page(acknowledgements) = page[
    = Acknowledgements

    #set par(first-line-indent: 3em, leading: 0.75em, spacing: 0.75em)

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

#let abstract-page(abstract, keywords) = page[
    = Abstract

    #par(leading: 0.75em, abstract)

    #v(1.5cm)

    Keywords: #keywords.join("; ")\.
]

#let resumo-page(abstract, keywords, title: none) = page[
    #if title != none {
        align(center + top, strong(title))
    }

    = Resumo

    #par(leading: 0.75em, abstract)

    #v(1.5cm)

    Palavras-chave: #keywords.join("; ")\.
]

#let print-glossary-title(entry) = {
    let short = entry.at("short")
    let long = entry.at("long")

    box(width: 1fr, short); box(width: 4fr, long);
}

#let glossary-page(terms) = page[
    = List of Abbreviations and Acronyms

    #{
        set strong(delta: 0)
        print-glossary(terms, show-all: true, disable-back-references: true, user-print-title: print-glossary-title)
    }
]
