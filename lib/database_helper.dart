import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get instance async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String dbPath = '';

    // 🟢১. প্ল্যাটফর্ম সনাক্তকরণ ও সঠিক পাথ নির্ধারণ (উইন্ডোজ বনাম মোবাইল)
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      final appDocDir = await getApplicationSupportDirectory();
      dbPath = join(appDocDir.path, "masayel_app", "masayel.db");
    } else {
      var databasesPath = await getDatabasesPath();
      dbPath = join(databasesPath, "masayel.db");
    }

    // 🟢২. উইন্ডোজের জন্য ডিরেক্টরি তৈরি নিশ্চিত করা
    try {
      await Directory(dirname(dbPath)).create(recursive: true);
    } catch (e) {
      debugPrint("Directory creation error: $e");
    }

    // 🟢৩. Assets থেকে masayel.db কপি করা (যদি আগে থেকে না থাকে)
    bool exists = await databaseExists(dbPath);

    if (!exists) {
      try {
        debugPrint("Copying database to: $dbPath");
        ByteData data = await rootBundle.load(join("assets/database", "masayel.db"));
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes, flush: true);
        debugPrint("Database successfully copied!");
      } catch (e) {
        debugPrint("Error copying database from assets: $e");
      }
    }

    return await openDatabase(dbPath);
  }

  static Future<List<String>> getCategories() async {
    final db = await instance;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT category FROM masayel'
    );
    return List.generate(maps.length, (i) => maps[i]['category'] as String);
  }

  static Future<List<Map<String, dynamic>>> getMasayelByCategory(String category) async {
    final db = await instance;
    return await db.query(
      'masayel',
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  static Future<List<Map<String, dynamic>>> searchMasayel(String query) async {
    final db = await instance;
    return await db.query(
      'masayel',
      where: 'title LIKE ? OR question LIKE ? OR answer LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
  }

  static Future<int> insertNewMasayel(List<dynamic> newMasayelList) async {
    final db = await instance;
    int addedCount = 0;

    for (var item in newMasayelList) {
      if (item is Map<String, dynamic>) {
        int result = await db.insert(
          'masayel',
          item,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );

        if (result > 0) {
          addedCount++;
        }
      }
    }
    return addedCount;
  }

  static Future<Map<String, dynamic>?> getMasalaById(int id) async {
    final db = await instance;
    final List<Map<String, dynamic>> results = await db.query(
      'masayel',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getRandomMasalaForNotification() async {
    final db = await instance;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM masayel ORDER BY RANDOM() LIMIT 1'
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
}