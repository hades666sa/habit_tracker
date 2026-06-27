import '../database_helper.dart';
import '../models/user_profile.dart';

class UserRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<UserProfile> getProfile() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('user_profile', where: 'id = 1');
    if (maps.isEmpty) {
      return UserProfile(name: '', focusAreas: []);
    }
    return UserProfile.fromMap(maps.first);
  }

  Future<int> updateProfile(UserProfile profile) async {
    final db = await dbHelper.database;
    return await db.update('user_profile', profile.toMap(), where: 'id = 1');
  }
}
