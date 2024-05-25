class Grupo {
  final int? idGrupo; // Change to int?
  final String titulo;
  final int categoria;

  Grupo({
    this.idGrupo, // Change to int?
    required this.titulo,
    required this.categoria,
  });

  factory Grupo.fromMap(Map<String, dynamic> map) {
    return Grupo(
      idGrupo: map['id_grupo'],
      titulo: map['titulo'],
      categoria: map['categoria'],
    );
  }

  @override
  String toString() {
    return 'Grupo{idGrupo: $idGrupo, titulo: $titulo, categoria: $categoria}';
  }

  Map<String, dynamic> toMap() {
    var map = {
      'titulo': titulo,
      'categoria': categoria,
    };
    if (idGrupo != null) {
      map['id_grupo'] = idGrupo!;
    }
    return map;
  }
}
