#let bachelors(title, course) = [
    Monograph presented as a partial requirement
    for the degree of #title in #course
]

#let inf-ufrgs = (
    name: [Instituto de Informática],
    department-ina: [Departamento de Informática Aplicada],
    department-int: [Departamento de Informática Teórica],
    director: ([Diretora do Instituto de Informática], [Prof#super[a]. Carla Maria Dal Sasso Freitas]),
    librarian: ([Bibliotecário-Chefe do Instituto de Informática], [Alexsander Borges Ribeiro]),
    cic-coord: ([Coordenador do Curso de Ciência de Computação], [Prof. Marcelo Walter]),
)

#let ufrgs = (
    name: [Universidade Federal do Rio Grande do Sul],
    location: [Porto Alegre, RS],
    nominata: (
        ([Reitor], [Prof. Carlos André Bulhões]),
        ([Vice-Reitora], [Prof#super[a]. Patricia Pranke]),
        ([Pró-Reitor de Graduação], [Prof. Júlio Otávio Jardim Barcellos])
    ),
    courses: (
        cic: (
            name: [Computer Science],
            program: [Bachelor of Science in Computer Science],
            title: [Bachelor],
            department: inf-ufrgs.name,
            nominata: (
                inf-ufrgs.director,
                inf-ufrgs.cic-coord,
                inf-ufrgs.librarian
            )
        )
    )
)
