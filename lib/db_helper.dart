import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  ///singleton
  DBHelper._();

  static DBHelper getInstance() => DBHelper._();

  Database? mDB;
  static String dbName = "todoDB.db";
  static String tableName = "todo";
  static String columnTodoId = "t_id";
  static String columnTodoTitle = "t_title";
  static String columnTodoDesc = "t_desc";
  static String columnTodoIsCompleted = "t_is_completed";

  ///1->true, 0->false
  static String columnTodoPriority = "t_priority";
  static String columnTodoCreatedAt = "t_created_at";

  Future<Database> initDB() async {
    mDB ??= await openDB();
    return mDB!;
  }

  Future<Database> openDB() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDocDir.path, dbName);

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) {
        ///create tables here

        db.execute(
          "create table $tableName ( $columnTodoId integer primary key autoincrement, $columnTodoTitle text, $columnTodoDesc text, $columnTodoIsCompleted integer, $columnTodoPriority integer, $columnTodoCreatedAt text)",
        );
      },
    );
  }

  ///queries
  Future<bool> addTodo({
    required String title,
    required String desc,
    required int priority,
  }) async {
    var db = await initDB();

    int rowsEffected = await db.insert(tableName, {
      columnTodoTitle: title,
      columnTodoDesc: desc,
      columnTodoIsCompleted: 0,
      columnTodoPriority: priority,
      columnTodoCreatedAt: DateTime.now().millisecondsSinceEpoch.toString(),
    });

    return rowsEffected > 0;
  }

  Future<List<Map<String, dynamic>>> getAllTodo() async {
    var db = await initDB();

    return await db.query(tableName);
  }

  Future<bool> completeTodo({required int id, required bool isComplete}) async {
    var db = await initDB();

    int rowsEffected = await db.update(
      tableName,
      {columnTodoIsCompleted: isComplete ? 1 : 0},
      where: "$columnTodoId = ?",
      whereArgs: ["$id"],
    );

    return rowsEffected > 0;
  }
}
