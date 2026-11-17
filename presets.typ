#let inf-ufrgs = (
    name: [Instituto de Informática],
    department-ina: [Departamento de Informática Aplicada],
    department-int: [Departamento de Informática Teórica],
    director: ([Diretor do Instituto de Informática], [Prof. Luciano Paschoal Gaspary]),
    librarian: ([Bibliotecário-chefe do Instituto de Informática], [Alexsander Borges Ribeiro]),
    cic-coord: ([Coordenador do Curso de Ciência de Computação], [Prof. Álvaro Freitas Moreira]),
)

#let ufrgs = (
    name: [Universidade Federal do Rio Grande do Sul],
    location: [Porto Alegre, RS],
    nominata: (
        ([Reitora], [Prof#super[a]. Marcia Cristina Bernardes Barbosa]),
        ([Vice-Reitor], [Prof. Pedro de Almeida Costa]),
        ([Pró-Reitora de Graduação], [Prof#super[a]. Nádya Pesce da Silveira])
    ),
    courses: (
        cic: (
            // Translatable fields are (en: ..., pt: ...) dictionaries,
            // resolved for the document language (see `localize`).
            name: (en: [Computer Science], pt: [Ciência da Computação]),
            program: (
                en: [Bachelor of Science in Computer Science],
                pt: [Curso de Ciência da Computação],
            ),
            title: (en: [Bachelor], pt: [Bacharel]),
            department: inf-ufrgs.name,
            nominata: (
                inf-ufrgs.director,
                inf-ufrgs.cic-coord,
                inf-ufrgs.librarian
            )
        )
    )
)
