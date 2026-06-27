import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:home_widget/home_widget.dart';
import 'app.dart';
import 'providers/habit_provider.dart';
import 'providers/habit_log_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/mood_provider.dart';
import 'utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fire and forget notification initialization to prevent blocking the first frame
  NotificationService.init().then((_) {
    NotificationService.requestPermissions();
  });

  // Initialize HomeWidget so the SharedPreferences bridge works correctly
  HomeWidget.setAppGroupId('com.loop.habittracker.habit_tracker_flutter');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider()..loadHabits()),
        ChangeNotifierProvider(create: (_) => HabitLogProvider()..loadTodayLogs()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()..loadAchievements()),
        ChangeNotifierProvider(create: (_) => JournalProvider()..fetchJournals()),
        ChangeNotifierProvider(create: (_) => MoodProvider()..loadMoods()),
      ],
      child: const App(),
    ),
  );
}
