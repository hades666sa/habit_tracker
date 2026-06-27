import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/habit_log.dart';

class HabitLogRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertOrUpdate(HabitLog log) async {
    final db = await dbHelper.database;
    return await db.insert(
      DatabaseHelper.tableHabitLogs,
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HabitLog>> getLogsForHabit(int habitId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableHabitLogs,
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
    return maps.map((m) => HabitLog.fromMap(m)).toList();
  }

  Future<HabitLog?> getLogForDate(int habitId, String date) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableHabitLogs,
      where: 'habit_id = ? AND log_date = ?',
      whereArgs: [habitId, date],
    );
    if (maps.isEmpty) return null;
    return HabitLog.fromMap(maps.first);
  }

  Future<List<HabitLog>> getLogsForDate(String date) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableHabitLogs,
      where: 'log_date = ?',
      whereArgs: [date],
    );
    return maps.map((m) => HabitLog.fromMap(m)).toList();
  }
  
  Future<List<HabitLog>> getLogsBetweenDates(String startDate, String endDate) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableHabitLogs,
      where: 'log_date >= ? AND log_date <= ?',
      whereArgs: [startDate, endDate],
    );
    return maps.map((m) => HabitLog.fromMap(m)).toList();
  }

  Future<List<String>> getCompletedDatesForHabit(int habitId, int targetCount) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableHabitLogs,
      columns: ['log_date'],
      where: 'habit_id = ? AND completions_count >= ?',
      whereArgs: [habitId, targetCount],
      orderBy: 'log_date DESC',
    );
    return maps.map((m) => m['log_date'] as String).toList();
  }

  Future<Map<int, List<String>>> getAllCompletedDates(Map<int, int> habitTargets) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableHabitLogs,
      columns: ['habit_id', 'log_date', 'completions_count'],
      where: 'completions_count > 0',
      orderBy: 'log_date DESC',
    );
    
    Map<int, List<String>> result = {};
    for (var map in maps) {
      final habitId = map['habit_id'] as int;
      final count = map['completions_count'] as int;
      final date = map['log_date'] as String;
      
      final target = habitTargets[habitId] ?? 1;
      if (count >= target) {
        result.putIfAbsent(habitId, () => []).add(date);
      }
    }
    return result;
  }

  // Deprecated: use getLogsBetweenDates to prevent memory bloat
  Future<List<HabitLog>> getAllLogs() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableHabitLogs);
    return maps.map((m) => HabitLog.fromMap(m)).toList();
  }
}
