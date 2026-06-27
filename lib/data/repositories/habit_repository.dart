import '../database_helper.dart';
import '../models/habit.dart';

class HabitRepository {
  final DatabaseHelper dbHelper;
  
  HabitRepository({DatabaseHelper? helper}) : dbHelper = helper ?? DatabaseHelper.instance;

  Future<int> insert(Habit habit) async {
    final db = await dbHelper.database;
    return await db.insert('habits', habit.toMap());
  }

  Future<List<Habit>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('habits', orderBy: 'sort_order ASC');
    return maps.map((m) => Habit.fromMap(m)).toList();
  }

  Future<int> update(Habit habit) async {
    final db = await dbHelper.database;
    return await db.update('habits', habit.toMap(), where: 'id = ?', whereArgs: [habit.id]);
  }

  Future<void> updateAll(List<Habit> habits) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (var habit in habits) {
      batch.update('habits', habit.toMap(), where: 'id = ?', whereArgs: [habit.id]);
    }
    await batch.commit(noResult: true);
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }
}

