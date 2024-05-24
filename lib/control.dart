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
      "",
    );
  }

  Future insertDatabase(Grupo grupo) async {
    Database db = await startDatabase();
    await db.execute(
      """
      CREATE TABLE IF NOT EXISTS grupos (
        id_grupo INTEGER PRIMARY KEY,
        titulo VARCHAR(200) DEFAULT NULL,
        categoria INTEGER NOT NULL,
        FOREIGN KEY (categoria) REFERENCES categorias(id_categoria)
       );
      """
    );
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
}