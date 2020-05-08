import 'package:counter/model/counter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class CounterRepository {

  static const String TABLE_NAME = 'counter';
  static const String COL_ID = 'id';
  static const String COL_NAME = 'name';
  static const String COL_VALUE = 'value';

  static final Future<Database> _database = _getDatabase();

  static Future<Database> _getDatabase() async => openDatabase(
    join(await getDatabasesPath(), 'counter.db'),
    onCreate: (db, version) {
      return db.execute('''
        CREATE TABLE $TABLE_NAME (
          $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          $COL_NAME TEXT,
          $COL_VALUE INTEGER
        );
      ''');
    },
    version: 1,
  );

  static Future<Counter> create([String name, int value = 0]) async {
    final Database db = await _database;
    int id = await db.insert(
        TABLE_NAME,
        {
          CounterRepository.COL_NAME: name,
          CounterRepository.COL_VALUE: value,
        },
        conflictAlgorithm: ConflictAlgorithm.replace
    );
    return new Counter(name, value, id);
  }

  static Future<void> update(Counter counter) async {
    final db = await _database;
    await db.update(
      TABLE_NAME,
      counter.toMap(),
      where: "$COL_ID = ?",
      whereArgs: [counter.id],
    );
  }

  static Future<void> delete(int id) async {
    final db = await _database;
    await db.delete(
      TABLE_NAME,
      where: "$COL_ID = ?",
      whereArgs: [id],
    );
  }

  static Future<List<Counter>> getAll() async {
    final Database db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(TABLE_NAME);
    return List.generate(maps.length, (i) {
      return Counter(
        maps[i][COL_NAME],
        maps[i][COL_VALUE],
        maps[i][COL_ID],
      );
    });
  }

}
