# Flutter-specific ProGuard rules

# Keep the HabitWidgetProvider so Android can instantiate it
-keep class com.loop.habittracker.habit_tracker_flutter.HabitWidgetProvider { *; }

# Keep the MainActivity for deep link handling
-keep class com.loop.habittracker.habit_tracker_flutter.MainActivity { *; }

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# home_widget package
-keep class es.antonborri.home_widget.** { *; }

# Keep SharedPreferences access (used by widget)
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$Editor { *; }
