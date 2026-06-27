import '../database_helper.dart';
import '../models/achievement.dart';

class AchievementRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Achievement>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('achievements');
    return maps.map((m) => Achievement.fromMap(m)).toList();
  }

  Future<int> update(Achievement achievement) async {
    final db = await dbHelper.database;
    return await db.update(
      'achievements', 
      achievement.toMap(), 
      where: 'id = ?', 
      whereArgs: [achievement.id]
    );
  }
}
