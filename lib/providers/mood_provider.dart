import 'package:flutter/foundation.dart';
import '../data/models/mood_entry.dart';
import '../data/repositories/mood_repository.dart';
import '../utils/date_utils.dart';

class MoodProvider with ChangeNotifier {
  final MoodRepository _repository = MoodRepository();
  List<MoodEntry> _moods = [];
  Map<String, MoodEntry> _moodMap = {};

  List<MoodEntry> get moods => _moods;
  Map<String, MoodEntry> get moodMap => _moodMap;

  Future<void> loadMoods() async {
    _moods = await _repository.getAllMoods();
    _moodMap = {for (var m in _moods) m.date: m};
    notifyListeners();
  }

  Future<void> saveMood(String mood, String? feeling) async {
    final now = DateTime.now();
    final dateStr = AppDateUtils.formatDate(now);
    
    final entry = MoodEntry(
      date: dateStr,
      mood: mood,
      feeling: feeling,
      createdAt: now,
    );
    
    await _repository.insertOrUpdate(entry);
    await loadMoods();
  }

  MoodEntry? getMoodForDate(String date) => _moodMap[date];
}
