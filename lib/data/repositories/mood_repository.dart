import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/mood_entry.dart';

class MoodRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertOrUpdate(MoodEntry entry) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'mood_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MoodEntry?> getMoodForDate(String date) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mood_entries',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (maps.isEmpty) return null;
    return MoodEntry.fromMap(maps.first);
  }

  Future<List<MoodEntry>> getAllMoods() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('mood_entries', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => MoodEntry.fromMap(maps[i]));
  }
}
