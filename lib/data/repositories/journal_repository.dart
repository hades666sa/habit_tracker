import '../database_helper.dart';
import '../models/journal.dart';

class JournalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertJournal(Journal journal) async {
    final db = await _dbHelper.database;
    return await db.insert('journals', journal.toMap());
  }

  Future<List<Journal>> getAllJournals() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('journals', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => Journal.fromMap(maps[i]));
  }

  Future<int> updateJournal(Journal journal) async {
    final db = await _dbHelper.database;
    return await db.update(
      'journals',
      journal.toMap(),
      where: 'id = ?',
      whereArgs: [journal.id],
    );
  }

  Future<int> deleteJournal(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'journals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
