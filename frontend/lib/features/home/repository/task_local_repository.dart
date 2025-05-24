import 'package:frontend/models/task.models.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TaskLocalRepository {
  String tableName = 'tasks';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "tasks.db");

    //await deleteDatabase(path);

    return openDatabase(
      path,
      version: 8,
      // onUpgrade: (db, oldVersion, newVersion) async {
      //   if (oldVersion < newVersion) {
      //     await db.execute(
      //       'ALTER TABLE $tableName ADD COLUMN isSynced INTEGER NOT NULL',
      //     );
      //   }
      // },
      onCreate: (db, version) {
        return db.execute('''
            CREATE TABLE $tableName(
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              description TEXT NOT NULL,
              uid TEXT NOT NULL,
              dueAt TEXT NOT NULL,
              hexColor TEXT NOT NULL,
              createdAt TEXT NOT NULL,
              updatedAt TEXT NOT NULL,
              isSynced INTEGER NOT NULL,
              dueTime TEXT NOT NULL
            )
      ''');
      },
    );
  }

  Future<void> insertTask(TaskModel tasks) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [tasks.id]);
    await db.insert(tableName, tasks.toMap());
  }

  Future<void> insertTasks(List<TaskModel> tasks) async {
    final db = await database;
    final batch = db.batch();
    for (var task in tasks) {
      batch.insert(
        tableName,
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(tableName);
    //print('line 73 from local_repo: ${result}');
    if (result.isNotEmpty) {
      List<TaskModel> tasks = [];
      for (var elem in result) {
        tasks.add(TaskModel.fromMap(elem));
      }
      return tasks;
    }

    return [];
  }
// ye issue de rha h
  Future<List<TaskModel>> getUnsyncedTasks() async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    //print(result);
    if (result.isNotEmpty) {
      List<TaskModel> tasks = [];
      for (var elem in result) {
        tasks.add(TaskModel.fromMap(elem));
      }
      return tasks;
    }
    //print('No unsynced tasks found');

    return [];
  }

  Future<void> updateRowValue(String id, int newValue) async {
    final db = await database;
    await db.update(
      tableName,
      {'isSynced': newValue},
      where: 'id = ?',
      whereArgs: [id],
    );
    //print(result);
  }
}
