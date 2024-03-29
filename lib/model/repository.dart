// ignore_for_file: constant_identifier_names

import 'dart:developer' as developer;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'objects/counter.dart';
import 'objects/event.dart';


class Repository {

  static const String TAB_COUNTER = 'counter';
  static const String TAB_EVENT = 'event';
  static const String COL_ID = 'id';

  // tab COUNTER columns
  static const String COL_NAME = 'name';
  static const String COL_VALUE = 'value'; // obsolete since DBv2
  // tab EVENT columns
  static const String COL_C_ID = 'counter_id';
  static const String COL_TIME = 'time';
  static const String COL_NOTE = 'note';

  static final Future<Database> _database = _getDatabase();

  static Future<Database> _getDatabase() async => openDatabase(
    join((await getDatabasesPath()), 'counter.db'),
    onConfigure: (db) {
      // Enable foreign key constraints
      db.execute('PRAGMA foreign_keys=ON;');
    },
    onCreate: (db, version) {
      return db.transaction((txn) async {
        await txn.execute('''
          CREATE TABLE $TAB_COUNTER (
            $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            $COL_NAME TEXT
          );
        ''');
        await txn.execute('''
          CREATE TABLE $TAB_EVENT (
            $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            $COL_C_ID INTEGER NOT NULL,
            $COL_TIME INTEGER DEFAULT (
              cast((strftime('%s','now') || substr(strftime('%f','now'),4))
                as int)
            ),
            $COL_NOTE TEXT,
            FOREIGN KEY ($COL_C_ID) REFERENCES $TAB_COUNTER($COL_ID)
              ON DELETE CASCADE ON UPDATE CASCADE
          );
        ''');
        await txn.execute('''
          CREATE INDEX index_${TAB_EVENT}_$COL_C_ID ON $TAB_EVENT ($COL_C_ID);
        ''');
      });
    },
    version: 3,
    onUpgrade: (db, oldVersion, newVersion) async {
      developer.log('Upgrading database form $oldVersion to $newVersion');
      if (oldVersion < 2) {
        await db.transaction((txn) async {
          await txn.execute('''
            CREATE TABLE event (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              counter_id INTEGER NOT NULL,
              time INTEGER DEFAULT (
                cast((strftime('%s','now') || substr(strftime('%f','now'),4))
                  as int)),
              FOREIGN KEY (counter_id) REFERENCES counter(id)
                ON DELETE CASCADE ON UPDATE CASCADE
            );
          ''');
          await txn.execute('''
            CREATE INDEX index_event_counter_id ON event (counter_id);
          ''');
        });
      }
      if (oldVersion < 3) {
        await db.transaction((txn) async {
          await txn.execute('''
            ALTER TABLE event ADD COLUMN note TEXT;
          ''');
        });
      }
    },
  );

  static Future<Counter> create([String? name]) async {
    final Database db = await _database;
    int id = await db.insert(
        TAB_COUNTER,
        {
          Repository.COL_NAME: name,
        },
        conflictAlgorithm: ConflictAlgorithm.replace
    );
    return Counter(name, 0, id);
  }

  static Future<void> update(Counter counter) async {
    final db = await _database;
    await db.update(
      TAB_COUNTER,
      counter.toMap(),
      where: "$COL_ID = ?",
      whereArgs: [counter.id],
    );
  }

  static Future<void> inc(Counter counter) async {
    final db = await _database;
    await db.insert(
      TAB_EVENT,
      {
        Repository.COL_C_ID: counter.id,
      },
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  static Future<void> delete(int? id) async {
    final db = await _database;
    await db.delete(
      TAB_COUNTER,
      where: "$COL_ID = ?",
      whereArgs: [id],
    );
  }

  static Future<void> reset(int counterId) async {
    final db = await _database;
    await db.delete(
      TAB_EVENT,
      where: "$COL_C_ID = ?",
      whereArgs: [counterId],
    );
  }

  static Future<List<Counter>> getAll() async {
    final Database db = await _database;
    const ALIAS_VALUE = 'value';
    const ALIAS_LAST = 'last_event';
    // Alternative query with subquery
    //SELECT counter.id, counter.name,
    //  (SELECT COUNT(id) FROM event WHERE event.counter_id = counter.id) as value
    //  (SELECT MAX(time) FROM event WHERE event.counter_id = counter.id) as last_event
    //FROM counter ORDER BY counter.name, counter.id
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT $TAB_COUNTER.$COL_ID, $TAB_COUNTER.$COL_NAME,
        COUNT($TAB_EVENT.$COL_C_ID) as $ALIAS_VALUE,
        MAX($TAB_EVENT.$COL_TIME) as $ALIAS_LAST
      FROM $TAB_COUNTER LEFT OUTER JOIN $TAB_EVENT
        ON $TAB_COUNTER.$COL_ID = $TAB_EVENT.$COL_C_ID
      GROUP BY $TAB_COUNTER.$COL_ID
      ORDER BY $TAB_COUNTER.$COL_NAME, $TAB_COUNTER.$COL_ID;
    ''');
    return List.generate(maps.length, (i) {
      return Counter(
        maps[i][COL_NAME],
        maps[i][ALIAS_VALUE],
        maps[i][COL_ID],
        maps[i][ALIAS_LAST] != null
            ? DateTime.fromMillisecondsSinceEpoch(maps[i][ALIAS_LAST])
            : null
      );
    });
  }

  static Future<Counter?> get(int id) async {
    final Database db = await _database;
    List<Map<String, dynamic>> maps = await db.query(TAB_COUNTER,
        columns: [COL_ID, COL_NAME], where: "$COL_ID = ?", whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Counter(maps[0][COL_NAME], 0, maps[0][COL_ID]);
  }

  static Future<List<Event>> getAllCounterEvents(int? counterId) async {
    final Database db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(TAB_EVENT,
        columns: [COL_ID, COL_TIME, COL_NOTE],
        where: "$COL_C_ID = ?",
        whereArgs: [counterId],
        orderBy: '$COL_TIME DESC');
    return List.generate(maps.length, (i) {
      return Event(
        maps[i][COL_ID],
        DateTime.fromMillisecondsSinceEpoch(maps[i][COL_TIME]),
        maps[i][COL_NOTE],
      );
    });
  }

  static Future<Event> createEvent(Counter counter, DateTime time, String? note) async {
    final Database db = await _database;
    int id = await db.insert(
        TAB_EVENT,
        {
          Repository.COL_C_ID: counter.id,
          Repository.COL_TIME: time.millisecondsSinceEpoch,
          Repository.COL_NOTE: note
        },
        conflictAlgorithm: ConflictAlgorithm.replace
    );
    return Event(id, time, note);
  }

  static Future<void> deleteEvent(int? id) async {
    final db = await _database;
    await db.delete(
      TAB_EVENT,
      where: "$COL_ID = ?",
      whereArgs: [id],
    );
  }

  static Future<void> addEventNote(int? id, String note) async {
    final db = await _database;
    await db.update(
      TAB_EVENT,
      {
        Repository.COL_NOTE: note,
      },
      where: "$COL_ID = ?",
      whereArgs: [id],
    );
  }

  static Future<void> updateEventTime(int? id, DateTime time) async {
    final db = await _database;
    await db.update(
      TAB_EVENT,
      {
        Repository.COL_TIME: time.millisecondsSinceEpoch,
      },
      where: "$COL_ID = ?",
      whereArgs: [id],
    );
  }

}
