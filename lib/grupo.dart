class Grupo {
  final String titulo ;
  final int categoria ;

  @override
  String toString() {
    return 'Grupo{titulo: $titulo, categoria: $categoria}';
  }

  const Grupo(
      {
        required this.titulo,
        required this.categoria,
      });

  Map<String, dynamic> toMap(){
    return {
      'titulo': titulo,
      'categoria': categoria,
    };
  }

}



