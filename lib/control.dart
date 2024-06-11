import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'grupo.dart';

class Control {
  static const _databaseName = "projeto.db";
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
    await db.execute('''
      CREATE TABLE releitura (
        id_releitura INTEGER PRIMARY KEY AUTOINCREMENT,
        id_entrada INTEGER,
        releitura INTEGER,
        quantidade NUMERIC(10,2),
        inicio DATE,
        fim DATE,
        FOREIGN KEY (id_entrada) REFERENCES entrada(id_entrada)
      );
    ''');
    await db.execute('''
      CREATE TABLE lancamentos (
        id_lancamento INTEGER PRIMARY KEY AUTOINCREMENT,
        id_grupo INTEGER,
        titulo VARCHAR(200),
        lancamento DATE,
        FOREIGN KEY (id_grupo) REFERENCES grupos(id_grupo)
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
    return await db.rawQuery(
        'SELECT * FROM grupos WHERE titulo LIKE ? ORDER BY titulo',
        ['%$parametro%']
    );
  }

  Future<List<Map<String, dynamic>>> queryFindCategoria(int categoria) async {
    Database db = await startDatabase();
    return await db.query('grupos', where: 'categoria = ?', whereArgs: [categoria], orderBy: 'titulo');
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
    return await db.query(
        'entradas',
        where: 'titulo LIKE ?',
        whereArgs: ['%$titulo%'],
        orderBy: 'titulo'
    );
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
      // Delete entries in 'lancamentos' that have id_grupo = idGrupo
      await txn.delete(
        'lancamentos',
        where: 'id_grupo = ?',
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
    return await db.query(
        'autores',
        where: 'descricao_autor LIKE ?',
        whereArgs: ['%$authorName%'],
        orderBy: 'descricao_autor'
    );
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

  Future<bool> deleteAuthor(int idAutor, BuildContext context) async {
    Database db = await startDatabase();
    // Check if the author is being used by any entries
    List<Map<String, dynamic>> entries = await db.query(
      'entradas',
      where: 'autor = ?',
      whereArgs: [idAutor],
    );

    if (entries.isNotEmpty) {
      // Author is being used by an entry, show a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Author cannot be deleted because they are being used by an entry!'),
          duration: Duration(seconds: 3),
        ),
      );
      return false; // Return false indicating deletion was not performed
    }

    // Author is not being used, proceed with deletion
    await db.delete(
      'autores',
      where: 'id_autor = ?',
      whereArgs: [idAutor],
    );
    print('Author deleted!');
    return true; // Return true indicating deletion was successful
  }

  Future<void> clearDatabases() async {
    if (database == null) {
      return;
    }

    // Clearing grupos table
    await database!.delete('grupos');

    // Clearing entradas table
    await database!.delete('entradas');

    // Clearing releitura table
    await database!.delete('releitura');

    // Clearing autores table except for 'Unknown'
    await database!.delete('autores', where: 'descricao_autor <> ?', whereArgs: ['Unknown']);
  }

  Future<void> exportToSQL() async {
    try {
      String dbPath = '/data/data/com.example.projeto/databasesprojeto.db'; // Update with the correct path

      List<int> bytes = await File(dbPath).readAsBytes();

      String downloadsPath = '/storage/self/primary/Download'; // Use the correct Downloads path
      String sqlPath = join(downloadsPath, "exported_database.sql");
      File sqlFile = File(sqlPath);
      await sqlFile.writeAsBytes(bytes);

      print("Database exported to SQL file: $sqlPath");
    } catch (e) {
      print("Error exporting database to SQL: $e");
    }
  }

  Future<void> importDatabase(File importedDatabaseFile) async {
    try {
      // Open the imported database
      Database importedDb = await openDatabase(importedDatabaseFile.path);

      // Get the list of table names from the imported database
      List<Map<String, dynamic>> tableNames = await importedDb.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

      // Iterate over each table
      for (Map<String, dynamic> table in tableNames) {
        String tableName = table['name'] as String;

        // Skip system tables like 'android_metadata'
        if (tableName == 'android_metadata' || tableName.startsWith('sqlite_')) {
          continue;
        }

        // Retrieve data from the current table in the imported database
        List<Map<String, dynamic>> tableData = await importedDb.query(tableName);

        // Insert data into the corresponding table in the current database
        Database currentDb = await startDatabase();
        await currentDb.transaction((txn) async {
          for (Map<String, dynamic> row in tableData) {
            try {
              await txn.insert(tableName, row);
            } catch (e) {
              print("Skipping duplicate entry in table $tableName: $e");
            }
          }
        });
      }

      // Close the imported database
      await importedDb.close();

      print("Database content imported successfully.");
    } catch (e) {
      print("Error importing database content: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getRereadsByIdEntrada(int idEntrada) async {
    Database db = await startDatabase();
    return await db.query(
      'releitura',
      where: 'id_entrada = ?',
      whereArgs: [idEntrada],
      orderBy: 'inicio ASC',
    );
  }

  Future<void> insertReread(Map<String, dynamic> rereadData) async {
    Database db = await startDatabase();
    await db.insert('releitura', rereadData);
  }

  Future<Map<String, dynamic>?> getRereadById(int idReread) async {
    Database db = await startDatabase();
    List<Map<String, dynamic>> rereads = await db.query(
      'releitura',
      where: 'id_releitura = ?',
      whereArgs: [idReread],
    );
    if (rereads.isNotEmpty) {
      return rereads.first;
    } else {
      return null;
    }
  }

  Future<void> deleteReread(int idReread) async {
    Database db = await startDatabase();
    await db.delete(
      'releitura',
      where: 'id_releitura = ?',
      whereArgs: [idReread],
    );
    print('Reread deleted!');
  }

  Future<void> updateReread(int idReread, Map<String, dynamic> updatedData) async {
    Database db = await startDatabase();
    await db.update(
      'releitura',
      updatedData,
      where: 'id_releitura = ?',
      whereArgs: [idReread],
    );
    print('Reread updated!');
  }

  Future<List<Map<String, dynamic>>> getLancamentos() async {
    final Database db = await startDatabase();
    return await db.rawQuery('''
      SELECT lancamentos.id_lancamento, lancamentos.titulo AS lancamento_titulo,
             lancamentos.lancamento, grupos.titulo AS grupo_titulo
      FROM lancamentos
      INNER JOIN grupos ON lancamentos.id_grupo = grupos.id_grupo
      ORDER BY lancamentos.lancamento ASC
    ''');
  }

  Future<void> deleteLancamento(int idLancamento) async {
    final Database db = await startDatabase();
    await db.delete(
      'lancamentos',
      where: 'id_lancamento = ?',
      whereArgs: [idLancamento],
    );
  }

  Future<void> insertLancamento(int idGrupo, String titulo, String lancamento) async {
    await startDatabase();
    await database!.insert(
      'lancamentos',
      {
        'id_grupo': idGrupo,
        'titulo': titulo,
        'lancamento': lancamento,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

}
