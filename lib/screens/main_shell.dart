import 'package:flutter/material.dart';
import 'today/today_screen.dart';
import 'history/history_screen.dart';
import 'journal/journal_screen.dart';
import 'statistics/statistics_screen.dart';
import 'statistics/mood_stats_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TodayScreen(),
    const HistoryScreen(),
    const MoodStatsScreen(),
    const JournalScreen(),
    const StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const Drawer(
        backgroundColor: Colors.transparent,
        child: SettingsScreen(),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_emotions_outlined), label: 'Mood'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Report'),
        ],
      ),
    );
  }
}
