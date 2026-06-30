import 'dart:io';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/habit.dart';
import '../widgets/heatmap_grid.dart';
import 'date_utils.dart';
import 'streak_calculator.dart';
import 'widget_image_generator.dart';
import 'dart:ui' as ui;

class WidgetService {
  static const String androidCompactProvider = 'HabitWidgetCompactProvider';
  static const String androidSmallProvider = 'HabitWidgetSmallProvider';
  static const String androidMediumProvider = 'HabitWidgetMediumProvider';
  
  static Future<void> updateWidgetDataForHabit({
    required Habit habit,
    required Map<String, int> logs,
  }) async {
    // Yield to the event loop so the UI (e.g. checkmark ripples) can finish rendering before we do heavy work
    await Future.delayed(const Duration(milliseconds: 300));

    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString('themeMode') ?? 'system';
    
    // Calculate streak using DRY StreakCalculator
    int currentStreak = StreakCalculator.currentStreak(logs, habit.completionsPerDay);

    String streakStr = '🔥 $currentStreak Day Streak';
    String desc = habit.description.isNotEmpty ? habit.description : habit.frequency.toLowerCase();
    
    final hId = habit.id;
    final List<Future> saveFutures = [];

    saveFutures.add(HomeWidget.saveWidgetData<String>('app_theme', themeStr));

    // Save habit-specific keys
    saveFutures.add(HomeWidget.saveWidgetData<String>('habit_${hId}_name', habit.name));
    saveFutures.add(HomeWidget.saveWidgetData<String>('habit_${hId}_streak', streakStr));
    saveFutures.add(HomeWidget.saveWidgetData<String>('habit_${hId}_description', desc));
    saveFutures.add(HomeWidget.saveWidgetData<String>('habit_${hId}_icon', habit.icon));
    saveFutures.add(HomeWidget.saveWidgetData<String>('habit_${hId}_color', habit.color));

    // Save legacy keys to support unconfigured widgets
    saveFutures.add(HomeWidget.saveWidgetData<String>('habit_name', habit.name));
    saveFutures.add(HomeWidget.saveWidgetData<String>('habit_streak', streakStr));
    saveFutures.add(HomeWidget.saveWidgetData<String>('habit_description', desc));
    saveFutures.add(HomeWidget.saveWidgetData<String>('habit_icon', habit.icon));
    saveFutures.add(HomeWidget.saveWidgetData<String>('habit_color', habit.color));

    // Save recent 7 days for legacy dots
    final List<String> weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    for (int i = 0; i < 7; i++) {
      DateTime d = DateTime.now().subtract(Duration(days: i));
      String dateStr = AppDateUtils.formatDate(d);
      int comps = logs[dateStr] ?? 0;
      bool isDone = comps >= habit.completionsPerDay;
      
      // Habit-specific
      saveFutures.add(HomeWidget.saveWidgetData<bool>('habit_${hId}_completed_$i', isDone));
      saveFutures.add(HomeWidget.saveWidgetData<String>('habit_${hId}_day_$i', weekdays[d.weekday - 1]));
      saveFutures.add(HomeWidget.saveWidgetData<int>('habit_${hId}_count_$i', comps));
      
      // Legacy
      saveFutures.add(HomeWidget.saveWidgetData<bool>('habit_completed_$i', isDone));
      saveFutures.add(HomeWidget.saveWidgetData<String>('habit_day_$i', weekdays[d.weekday - 1]));
      saveFutures.add(HomeWidget.saveWidgetData<int>('habit_count_$i', comps));
    }

    // Execute all IPC calls concurrently
    await Future.wait(saveFutures);

    // Prepare temp dir for Isolate
    final tempDir = await getTemporaryDirectory();

    // Generate Heatmaps for small and medium via background Isolate
    final smallData = MonthlyGenerationData(
      habit: habit,
      logs: logs,
      sizeKey: 'small_$hId',
      themeStr: themeStr,
      tempDirPath: tempDir.path,
    );
    final smallImagePath = await generateMonthlyCalendarImageIsolated(smallData);
    
    if (smallImagePath != null) {
      await HomeWidget.saveWidgetData<String>('heatmap_image_small_$hId', smallImagePath);
      // Legacy
      await HomeWidget.saveWidgetData<String>('heatmap_image_small', smallImagePath);
    }

    final mediumData = HeatmapGenerationData(
      habit: habit,
      logs: logs,
      columns: 26,
      rows: 7,
      sizeKey: 'medium_$hId',
      themeStr: themeStr,
      tempDirPath: tempDir.path,
    );
    final mediumImagePath = await generateHeatmapImageIsolated(mediumData);
    
    if (mediumImagePath != null) {
      await HomeWidget.saveWidgetData<String>('heatmap_image_medium_$hId', mediumImagePath);
      // Legacy
      await HomeWidget.saveWidgetData<String>('heatmap_image_medium', mediumImagePath);
    }

    // Update all three Android Widgets
    await HomeWidget.updateWidget(androidName: androidCompactProvider);
    await HomeWidget.updateWidget(androidName: androidSmallProvider);
    await HomeWidget.updateWidget(androidName: androidMediumProvider);

    // Update iOS Widgets
    await HomeWidget.updateWidget(iOSName: 'HabitWidgetSmall');
    await HomeWidget.updateWidget(iOSName: 'HabitWidgetMedium');
  }
}
