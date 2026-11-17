// Fixed texts printed by the template, one dictionary per document language.
// The document language picks the dictionary; the `labels` parameter of
// `abnt` overrides single entries. Portuguese texts follow infufrgs.cls
// (\captionsbrazilian) where it has an equivalent.

#let default-labels = (
    en: (
        acknowledgements: [Acknowledgements],
        abstract: [Abstract],
        keywords: [Keywords],
        list-of-figures: [List of Figures],
        list-of-tables: [List of Tables],
        list-of-listings: [List of Listings],
        list-of-abbreviations: [List of Abbreviations and Acronyms],
        contents: [Contents],
        references: [References],
        glossary: [Glossary],
        appendix: [Appendix],
        annex: [Annex],
        source: [Source],
        chapter: [Chapter],
        section: [Section],
        subsection: [Subsection],
        subsubsection: [Subsubsection],
        paragraph: [Paragraph],
        advisor: [Advisor],
        co-advisor: [Co-advisor],
        approved-on: [Approved on],
        examining-committee: [Examining committee],
        catalog-card: [CIP --- Cataloging-in-Publication],
        catalog-card-nature: [Thesis (Bachelor)],
        catalog-card-title: [Título], // also uses "Título"
        bachelors-nature: (title, course) => [
            Work presented in partial fulfillment
            of the requirements for the degree of
            #title in #course
        ],
    ),
    pt: (
        acknowledgements: [Agradecimentos],
        abstract: [Resumo],
        keywords: [Palavras-chave],
        list-of-figures: [Lista de Figuras],
        list-of-tables: [Lista de Tabelas],
        list-of-listings: [Lista de Listagens],
        list-of-abbreviations: [Lista de Abreviaturas e Siglas],
        contents: [Sumário],
        references: [Referências],
        glossary: [Glossário],
        appendix: [Apêndice],
        annex: [Anexo],
        source: [Fonte],
        chapter: [Capítulo],
        section: [Seção],
        subsection: [Subseção],
        subsubsection: [Subsubseção],
        paragraph: [Parágrafo],
        advisor: [Orientador],
        co-advisor: [Coorientador],
        approved-on: [Aprovado em],
        examining-committee: [Banca examinadora],
        catalog-card: [CIP --- Catalogação na Publicação],
        catalog-card-nature: [Trabalho de conclusão (graduação)],
        catalog-card-title: [Título],
        bachelors-nature: (title, course) => [
            Monografia apresentada como requisito
            parcial para a obtenção do grau de
            #title em #course
        ],
    ),
)

#let languages = default-labels.keys()

// The document's labels: the defaults for `language` with `overrides` on top.
#let make-labels(language, overrides) = {
    assert(
        language in default-labels,
        message: "typst-ufrgs-abnt: unsupported language \"" + language
            + "\" (supported: " + languages.join(", ") + ")",
    )
    let unknown = overrides.keys().filter(k => k not in default-labels.at(language))
    assert(
        unknown.len() == 0,
        message: "typst-ufrgs-abnt: unknown labels: " + unknown.join(", "),
    )
    default-labels.at(language) + overrides
}

// Resolves translatable values in a preset: a dictionary whose keys are all
// language codes (e.g. `(en: [Computer Science], pt: [Ciência da Computação])`)
// becomes its entry for `language` (or its first entry, if that language is
// missing); other dictionaries and arrays are resolved recursively.
#let localize(value, language) = {
    if type(value) == dictionary {
        if value.len() > 0 and value.keys().all(k => k in languages) {
            value.at(language, default: value.values().first())
        } else {
            value.pairs().map(((k, v)) => (k, localize(v, language))).to-dict()
        }
    } else if type(value) == array {
        value.map(v => localize(v, language))
    } else {
        value
    }
}
