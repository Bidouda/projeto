import 'package:sqflite/sqflite.dart';
import 'grupo.dart';

class Control{
  static final _databaseName = "projeto.db";
  static Database? database;

  Control();

  Future startDatabase() async{
    if(database != null){
      return database;
    }
    database = await _openOrCreateDatabase();
    return database;
  }

  Future _openOrCreateDatabase() async{
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + _databaseName;
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async{
    await db.execute(
      """
      CREATE TABLE categorias (
        id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
        descricao_categoria VARCHAR(200) NOT NULL
      );
      
      INSERT INTO categorias (descricao_categoria) VALUES ("Current");
      INSERT INTO categorias (descricao_categoria) VALUES ("Paused");
      INSERT INTO categorias (descricao_categoria) VALUES ("Completed");
      INSERT INTO categorias (descricao_categoria) VALUES ("Dropped");
      INSERT INTO categorias (descricao_categoria) VALUES ("Planning");
      
      CREATE TABLE grupos (
        id_grupo INTEGER PRIMARY KEY,
        titulo VARCHAR(200) DEFAULT NULL,
        categoria INTEGER NOT NULL,
        FOREIGN KEY (categoria) REFERENCES categorias(id_categoria)
       );
      """,
    );
  }

  Future insertDatabase(Grupo grupo) async{
    Database db = await startDatabase();
    String sql="";
    sql = "INSERT INTO Grupos (titulo, categoria) VALUES ('" + grupo.titulo + "', " + grupo.categoria.toString() + ");";
    try {
      await db.rawInsert(sql);
      print('Cliente inserido!');
    } finally {
      //await db.close();
    }
  }

  Future<List<Map<String, dynamic>>> queryFind(String parametro) async{
    Database db = await startDatabase();
    return await (db.rawQuery('SELECT * FROM grupos WHERE titulo LIKE' + "'%" + parametro + "%'"));
  }
}