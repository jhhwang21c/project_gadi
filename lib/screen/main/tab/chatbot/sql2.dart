import 'dart:async';
import 'package:GADI/common/common.dart';
import 'package:langchain/langchain.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database; // Make _database nullable

  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    _database ??= await _initDB('artworks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    bool exists = await databaseExists(path);
    if (!exists) {
      print("Creating new copy from asset");
      await Directory(dirname(path)).create(recursive: true);
      ByteData data = await rootBundle.load('assets/$filePath');
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
    return await openDatabase(path, readOnly: false);
  }

  // Renamed from _query to query for public access
  Future<List<Map<String, dynamic>>> query(String q) async {
    final db = await database; // Ensure the database is initialized
    return await db.rawQuery(q);
  }
}

final dbh = DatabaseHelper.instance;

FutureOr<String> runSqliteQuery(String queryText,
    {ToolOptions? options}) async {
  //final db = sqlite3.open('assets/art_auction.sqlite');

  final List<Map<String, dynamic>> results = await dbh.query(queryText);
  // Create a StringBuffer to efficiently concatenate strings
  StringBuffer sb = StringBuffer();

  for (final row in results) {
    // Each 'row' is a Map<String, dynamic> representing a database row
    sb.writeAll(row.values, ' | '); // Separate each value with ' | '
    sb.write('\n'); // Add a new line after each row
  }

  return sb.toString(); // Convert the StringBuffer content to String
}

final runQueryTool = Tool.fromFunction(
  name: "runSqliteQuery",
  description:
  '''Run a sqlite query. Only provide the data asked. The table name is artworks. The columns are 
      title TEXT,
  artist TEXT,
  artist_in_korean TEXT,
  year TEXT,
  currency TEXT,
  price INTEGER,
  height REAL,
  width REAL,
  medium TEXT,
  description TEXT,
  auction_name TEXT,
  auction_date TEXT,
  total_views INTEGER,
  monthly_views INTEGER''',
  func: runSqliteQuery,
);
