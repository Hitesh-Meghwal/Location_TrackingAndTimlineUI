import 'dart:ffi';
import 'dart:math';

import 'package:path/path.dart';
import 'package:sampleapp/Models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseService {

  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _userTableName = "UserLocation";
  final String _userIdColName = "Id";
  final String _userNameColName = "UserName";
  final String _userLocationColName = "Location";
  final String _userTimestampColName = "TimeStamp";

  DatabaseService._constructor();

  Future<Database> get database async {
    if(_db != null) return _db!;
    //if null then if create db and then return
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    // path to database directory
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");

    //open database
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db,version){
        db.execute(
            """
            CREATE TABLE $_userTableName (
            $_userIdColName INTEGER PRIMARY KEY,
            $_userNameColName TEXT NOT NULL,
            $_userLocationColName TEXT,
            $_userTimestampColName INTEGER
            )
            """);
      }
    );
    return database;
  }

  // adding user to db
  void addUser(String userName, String userLocation, String userTimeStamp) async {
    final db = await database;
    await db.insert(_userTableName, {
      _userNameColName: userName,
      _userLocationColName: userLocation,
      _userTimestampColName: userTimeStamp
    });
  }

  Future<List<User>> getUser() async {
    final db = await database;
    final data = await db.query(_userTableName);
    List<User> user = data.map((e)=>User(e[_userNameColName] as String, e[_userLocationColName] as String, e[_userTimestampColName] as String)).toList();
    return user;
  }
}
