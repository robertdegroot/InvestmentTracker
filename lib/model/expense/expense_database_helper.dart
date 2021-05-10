import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'expense.dart';

class ExpenseDatabaseHelper {

  static final _databaseName = "ExpenseDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'expense_table';

  static final columnId = '_id';
  static final columnTimestamp = 'timestamp';
  static final columnAmount = 'amount';
  static final columnCategory = 'category';
  static final columnNote = 'note';

  ExpenseDatabaseHelper._privateConstructor();
  static final ExpenseDatabaseHelper instance = ExpenseDatabaseHelper._privateConstructor();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnTimestamp INTEGER NOT NULL,
            $columnAmount REAL NOT NULL,
            $columnCategory TEXT NOT NULL,
            $columnNote TEXT
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.rawQuery('SELECT * FROM $table ORDER BY $columnTimestamp DESC');
  }

  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> update(Map<String, Expense> row) async {
    Database db = await instance.database;
    int id = row[columnId].id;
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(table);
  }
}