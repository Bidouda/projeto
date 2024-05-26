import 'package:sqflite/sqflite.dart';
import 'grupo.dart';

class Control {
  static final _databaseName = "projeto.db";
  static Database? database;

  Control();

  Future startDatabase() async {
    if (database != null) {
      return database;
    }
    database = await _openOrCreateDatabase();
    return database;
  }

  Future _openOrCreateDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + _databaseName;
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
      """
      CREATE TABLE categorias (
        id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
        descricao_categoria VARCHAR(200) NOT NULL
      );
      """,
    );
    await db.execute('INSERT INTO categorias (descricao_categoria) VALUES ("Current");');
    await db.execute('INSERT INTO categorias (descricao_categoria) VALUES ("Paused");');
    await db.execute('INSERT INTO categorias (descricao_categoria) VALUES ("Completed");');
    await db.execute('INSERT INTO categorias (descricao_categoria) VALUES ("Dropped");');
    await db.execute('INSERT INTO categorias (descricao_categoria) VALUES ("Planning");');
    await db.execute("""
      CREATE TABLE grupos (
        id_grupo INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo VARCHAR(200) DEFAULT NULL,
        categoria INTEGER NOT NULL,
        FOREIGN KEY (categoria) REFERENCES categorias(id_categoria)
      );
    """);
    await db.execute("""
      CREATE TABLE tipo (
        id_tipo INTEGER PRIMARY KEY AUTOINCREMENT,
        descricao_tipo TEXT
      );
    """);
    await db.execute('INSERT INTO tipo (descricao_tipo) VALUES ("Novel");');
    await db.execute('INSERT INTO tipo (descricao_tipo) VALUES ("Novella");');
    await db.execute('INSERT INTO tipo (descricao_tipo) VALUES ("Short Story");');
    await db.execute('INSERT INTO tipo (descricao_tipo) VALUES ("Graphic Novel");');
    await db.execute('INSERT INTO tipo (descricao_tipo) VALUES ("Drama & Poetry");');
    await db.execute('''
      CREATE TABLE autores (
        id_autor INTEGER PRIMARY KEY AUTOINCREMENT,
        descricao_autor TEXT
      );
    ''');
    await db.execute('INSERT INTO autores (descricao_autor) VALUES ("Unknown")');
    await db.execute('''
      CREATE TABLE entradas (
        id_entrada INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo VARCHAR(200),
        grupo INTEGER,
        categoria INTEGER,
        tipo INTEGER,
        autor INTEGER,
        posicao INTEGER,
        progresso INTEGER,
        total INTEGER,
        inicio DATE,
        fim DATE,
        FOREIGN KEY (grupo) REFERENCES grupos(id_grupo),
        FOREIGN KEY (categoria) REFERENCES categorias(id_categoria),
        FOREIGN KEY (tipo) REFERENCES tipo(id_tipo),
        FOREIGN KEY (autor) REFERENCES autores(id_autor)
      );
    ''');
  }

  Future insertDatabase(Grupo grupo) async {
    Database db = await startDatabase();
    String sql = "";
    sql =
    "INSERT INTO grupos (titulo, categoria) VALUES ('${grupo.titulo}', ${grupo.categoria});";
    try {
      await db.rawInsert(sql);
      print('Grupo inserido!');
    }
    finally {
      //await db.close();
    }
  }

  Future<List<Map<String, dynamic>>> queryFind(String parametro) async {
    Database db = await startDatabase();
    return await (db.rawQuery(
        'SELECT * FROM grupos WHERE titulo LIKE' + "'%" + parametro + "%'"));
  }

  Future<List<Map<String, dynamic>>> queryFindCategoria(int categoria) async {
    Database db = await startDatabase();
    return await db.query('grupos', where: 'categoria = ?', whereArgs: [categoria]);
  }

  Future<void> insertEntrada(Map<String, dynamic> entrada) async {
    Database db = await startDatabase();
    await db.insert('entradas', entrada);
  }

  Future<List<Map<String, dynamic>>> getAllAuthors() async {
    Database db = await startDatabase();
    return await db.query('autores');
  }

  Future<void> insertAutor(String nome) async {
    Database db = await startDatabase();
    await db.insert('autores', {'descricao_autor': nome});
  }

  Future<List<Map<String, dynamic>>> queryFindGrupo(int grupo) async {
    Database db = await startDatabase();
    return await db.query('entradas', where: 'grupo = ?', whereArgs: [grupo], orderBy: 'posicao');
  }

  Future<List<Map<String, dynamic>>> queryFindEntradas(String titulo) async {
    Database db = await startDatabase();
    return await db.query('entradas', where: 'titulo LIKE ?', whereArgs: ['%$titulo%']);
  }

  Future<Map<String, dynamic>?> getEntradaById(int idEntrada) async {
    Database db = await startDatabase();
    List<Map<String, dynamic>> entradas = await db.query(
      'entradas',
      where: 'id_entrada = ?',
      whereArgs: [idEntrada],
    );
    if (entradas.isNotEmpty) {
      return entradas.first;
    } else {
      return null;
    }
  }

  Future<void> updateEntrada(int idEntrada, Map<String, dynamic> updatedData) async {
    Database db = await startDatabase();
    await db.update(
      'entradas',
      updatedData,
      where: 'id_entrada = ?',
      whereArgs: [idEntrada],
    );
  }

  Future<void> deleteEntrada(int idEntrada) async {
    Database db = await startDatabase();
    await db.delete(
      'entradas',
      where: 'id_entrada = ?',
      whereArgs: [idEntrada],
    );
  }

  Future<void> updateGrupo(int idGrupo, String titulo, int categoria) async {
    Database db = await startDatabase();
    await db.update(
      'grupos',
      {'titulo': titulo, 'categoria': categoria},
      where: 'id_grupo = ?',
      whereArgs: [idGrupo],
    );
    print('Grupo updated!');
  }

  Future<void> deleteGrupo(int idGrupo) async {
    Database db = await startDatabase();
    await db.transaction((txn) async {
      // Delete entries in 'entradas' that have grupo = idGrupo
      await txn.delete(
        'entradas',
        where: 'grupo = ?',
        whereArgs: [idGrupo],
      );
      // Delete the group itself
      await txn.delete(
        'grupos',
        where: 'id_grupo = ?',
        whereArgs: [idGrupo],
      );
    });
  }

  Future<String?> getGroupTitleById(int idGrupo) async {
    Database db = await startDatabase();
    List<Map<String, dynamic>> groups = await db.query(
      'grupos',
      columns: ['titulo'],
      where: 'id_grupo = ?',
      whereArgs: [idGrupo],
    );
    if (groups.isNotEmpty) {
      return groups.first['titulo'] as String?;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> queryFindAuthors(String authorName) async {
    Database db = await startDatabase();
    return await db.query('autores', where: 'descricao_autor LIKE ?', whereArgs: ['%$authorName%']);
  }

  Future<Map<String, dynamic>?> getAuthorById(int idAutor) async {
    Database db = await startDatabase();
    List<Map<String, dynamic>> authors = await db.query(
      'autores',
      where: 'id_autor = ?',
      whereArgs: [idAutor],
    );
    if (authors.isNotEmpty) {
      return authors.first;
    } else {
      return null;
    }
  }

  Future<void> updateAuthorDescription(int idAutor, String newDescricaoAutor) async {
    Database db = await startDatabase();
    await db.update(
      'autores',
      {'descricao_autor': newDescricaoAutor},
      where: 'id_autor = ?',
      whereArgs: [idAutor],
    );
  }

  Future<void> deleteAuthor(int idAutor) async {
    Database db = await startDatabase();
    await db.delete(
      'autores',
      where: 'id_autor = ?',
      whereArgs: [idAutor],
    );
    print('Author deleted!');
  }
}
