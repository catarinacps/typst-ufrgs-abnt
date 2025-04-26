#import "@preview/glossarium:0.5.4": print-glossary
#import "presets.typ": bachelors

#let blank-page() = page(align(center + bottom)[_Page intentionally left blank._])

#let cover-page(institution, course, author, advisor, date) = {
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

        align(right, block(width: 50%)[
            #set align(left)
            #set text(size: 10pt)
            #bachelors(course.title, course.name)
            #v(0.65em * 2)
            Advisor: #advisor.title #advisor.first-name #advisor.surname
        ])

        set align(bottom)

        upper()[
            #institution.location\
            #date.display("[year]")
        ]
    }))
}

#let nominata-page(institution, course) = page(align(bottom + left)[
    #upper(institution.name)\
    #(institution.nominata + course.nominata).map(it => it.join([: ])).join(linebreak())
])

#let abstract-page(abstract, keywords) = page[
    = Abstract

    #par(first-line-indent: 3em, leading: 0.75em, [#abstract])

    #v(1.5cm)

    *Keywords:* #keywords.join("; ")\.
]

#let glossary-page(terms) = page[
    = Glossary

    #set strong(delta: 0)
    #print-glossary(terms, disable-back-references: true)
]
