class Grupo {
  final String titulo;
  final int categoria;

  Grupo({
    required this.titulo,
    required this.categoria,
  });

  factory Grupo.fromMap(Map<String, dynamic> map) {
    return Grupo(
      titulo: map['titulo'],
      categoria: map['categoria'],
    );
  }

  @override
  String toString() {
    return 'Grupo{titulo: $titulo, categoria: $categoria}';
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'categoria': categoria,
    };
  }
}