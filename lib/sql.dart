import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Note {
  final int? id;
  final String title;
  final String content;
  Note({ this.id, required this.title, required this.content});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }
}

class Todo {
  final int? id;
  final String title;
  final int? value;
  Todo({ this.id, required this.title,  this.value=0});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'value': value,
    };
  }
}

class SqlHelper {
  Database? database;
  Future getDatabase() async {
    if (database != null) {
      return database;
    }
    database = await initDatabase();
    return database;
  }

  Future initDatabase() async {
    String path = join(
      await getDatabasesPath(),
      'Gdsc_Banha.db',
    );
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        Batch batch = db.batch();
        batch.execute('''
            CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT
            )
            ''');
        batch.execute('''
            CREATE TABLE todo (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            value INTEGER
            )
            ''');
        batch.commit();
      },
    );
  }

  Future insertNote(Note note) async {
    Database db = await getDatabase();
    Batch batch = db.batch();
    batch.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    batch.commit();
  }

  Future insertTodo(Todo todo) async {
    Database db = await getDatabase();
    Batch batch = db.batch();
    batch.insert(
      'todo',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    batch.commit();
  }

  Future<List<Map>>loadNote() async {
    Database db = await getDatabase();
    List<Map> maps = await db.query('notes');
    return List.generate(maps.length, (index) {
      return Note(
        id: maps[index]['id'],
        title: maps[index]['title'],
        content: maps[index]['content'],
      ).toMap();
    });
  }

  Future<List<Map>> loadTodo() async {
    Database db = await getDatabase();
    List<Map> maps = await db.query('todo');
    return List.generate(maps.length, (index) {
      return Todo(
        id: maps[index]['id'],
        title: maps[index]['title'],
        value: maps[index]['value'],
      ).toMap();
    });
  }

  Future updateNote(Note newNote) async {
    Database db = await getDatabase();
    await db.update(
      'notes',
      where: 'id= ?',
      whereArgs: [newNote.id],
      newNote.toMap(),
    );
  }

  Future  updatetodo(int id, int cvalue) async {
    Database db = await getDatabase();
    Map<String, dynamic> values = {
      'value': cvalue == 0 ? 1 : 0,
    };
    await db.update(
      'todo',
      where: 'id= ?',
      whereArgs: [id],
      values,
    );
  }

  Future  deleteAllNotes() async {
    Database db = await getDatabase();
    await db.delete('notes');
  }

  Future  deleteNote(int id) async {
    Database db = await getDatabase();
    await db.delete(
      'notes',
      where: 'id= ?',
      whereArgs: [id],
    );
  }

 Future deleteAllTodo() async {
    Database db = await getDatabase();
    await db.delete('todo');
  }
}
