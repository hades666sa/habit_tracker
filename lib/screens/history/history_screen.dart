import '../create_habit/create_habit_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/habit_log_provider.dart';
import '../../utils/date_utils.dart';
import '../../utils/streak_calculator.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/heatmap_grid.dart';
import '../habit_detail/habit_detail_screen.dart';
import '../../data/models/habit.dart';
import 'habit_detail_bottom_sheet.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _weeksToShow = 52; 
  final DateTime _displayDate = DateTime.now(); 

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, shape: BoxShape.circle),
            child: Icon(Icons.menu, color: textColor, size: 20),
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text("History", style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [], // Removed Calendar Icon as requested
      ),
      body: Consumer3<HabitProvider, HabitLogProvider, SettingsProvider>(
        builder: (context, habitProvider, logProvider, settings, _) {
          final habits = habitProvider.habits.where((h) => h.frequency != 'ONE_TIME').toList();
          if (habits.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("🌱", style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text("No habits to show history", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 18)),
            ]));
          }

          return Column(
            children: [
              if (settings.showStreakCount)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark 
                        ? [Colors.blueAccent.withOpacity(0.15), Colors.purpleAccent.withOpacity(0.15)]
                        : [Colors.blueAccent.withOpacity(0.08), Colors.purpleAccent.withOpacity(0.08)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      Text("Overall Performance", style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildGlobalStat("Habits", "${habits.length}", isDark),
                          _buildGlobalStat("Completions", "${_calcTotalCompletions(habits, logProvider)}", isDark),
                          _buildGlobalStat("Current Best", "${_calcGlobalBestStreak(habits, logProvider)}", isDark),
                        ],
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    final completions = logProvider.getCompletionsForHabit(habit.id!);
                    final currentStreak = StreakCalculator.currentStreak(completions, habit.completionsPerDay);
                    final longestStreak = StreakCalculator.longestStreak(completions, habit.completionsPerDay);
                    final totalCompletions = completions.length;

                    final habitColor = habit.parsedColor;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      color: isDark ? const Color(0xFF000000) : Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                      ),
                      child: InkWell(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => HabitDetailBottomSheet(habit: habit, logs: completions),
                        ),
                        onLongPress: () => _showHabitMenu(context, habit, habitProvider, logProvider),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(habit.icon, style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(habit.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                                        if (habit.description.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(habit.description, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
                                        ],
                                      ],
                                    ),
                                  ),
                                   Builder(
                                     builder: (context) {
                                       final todayStr = AppDateUtils.formatDate(DateTime.now());
                                       final isCompletedToday = (completions[todayStr] ?? 0) >= habit.completionsPerDay;
                                       return GestureDetector(
                                         onTap: () {
                                           logProvider.toggleCompletion(
                                             habit.id!, 
                                             todayStr, 
                                             habit.completionsPerDay
                                           );
                                         },
                                         child: Container(
                                           padding: const EdgeInsets.all(8),
                                           decoration: BoxDecoration(
                                             color: isCompletedToday ? habitColor.withOpacity(0.2) : Colors.transparent, 
                                             borderRadius: BorderRadius.circular(12),
                                             border: isCompletedToday ? null : Border.all(color: isDark ? Colors.white24 : Colors.black12),
                                           ),
                                           child: Icon(
                                             isCompletedToday ? Icons.check : Icons.circle_outlined, 
                                             color: isCompletedToday ? habitColor : (isDark ? Colors.white24 : Colors.black12), 
                                             size: 20
                                           ),
                                         ),
                                       );
                                     }
                                   ),
                                 ],
                               ),
                              const SizedBox(height: 16),
                              Builder(
                                builder: (context) {
                                  int yearsDiff = _displayDate.year - habit.createdAt.year;
                                  if (yearsDiff < 0) yearsDiff = 0;
                                  DateTime gridStartDate = DateTime(habit.createdAt.year + yearsDiff, habit.createdAt.month, habit.createdAt.day);
                                  DateTime gridEndDate = gridStartDate.add(const Duration(days: 364));

                                    return _weeksToShow == 4 
                                      ? _buildMonthCalendarGrid(_displayDate, completions, habitColor, habit.completionsPerDay, isDark)
                                      : HeatmapGrid(
                                          habitColor: habitColor,
                                          logs: completions,
                                          targetCount: habit.completionsPerDay,
                                          weeksToShow: _weeksToShow,
                                        );
                                }
                              ),
                              if (settings.showStreakCount) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(15)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatItem("Total", "$totalCompletions", isDark),
                                      _buildStatItem("Streak", "$currentStreak", isDark),
                                      _buildStatItem("Best", "$longestStreak", isDark),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (settings.showViewModeBottomBar)
                Padding(
                  padding: const EdgeInsets.fromLTRB(48, 0, 48, 12),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04), borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        _buildTimeOption(Icons.calendar_view_month, 4),
                        _buildTimeOption(Icons.calendar_view_week, 52),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateHabitScreen())),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildMonthCalendarGrid(DateTime displayDate, Map<String, int> logs, Color habitColor, int targetCount, bool isDark) {
    final firstDayOfMonth = DateTime(displayDate.year, displayDate.month, 1);
    final daysInMonth = DateTime(displayDate.year, displayDate.month + 1, 0).day;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 4, mainAxisSpacing: 4, childAspectRatio: 1.3),
        itemCount: daysInMonth,
        itemBuilder: (context, index) {
            final date = firstDayOfMonth.add(Duration(days: index));
            final isDone = (logs[AppDateUtils.formatDate(date)] ?? 0) >= targetCount;
            return Container(decoration: BoxDecoration(color: isDone ? habitColor : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04)), shape: BoxShape.circle));
          },
        ),
    );
  }

  Widget _buildTimeOption(IconData icon, int weeks) {
    final isSelected = _weeksToShow == weeks;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _weeksToShow = weeks),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: isSelected ? (isDark ? Colors.white12 : Colors.white) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 18, color: isSelected ? (isDark ? Colors.white : Colors.blueAccent) : Colors.grey),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(children: [Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54))]);
  }

  Widget _buildGlobalStat(String label, String value, bool isDark) {
    return Column(children: [Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))]);
  }

  int _calcTotalCompletions(List<Habit> habits, HabitLogProvider logProvider) {
    int total = 0;
    for (var habit in habits) { total += logProvider.getCompletionsForHabit(habit.id!).length; }
    return total;
  }

  int _calcGlobalBestStreak(List<Habit> habits, HabitLogProvider logProvider) {
    int best = 0;
    for (var habit in habits) {
      final streak = StreakCalculator.longestStreak(logProvider.getCompletionsForHabit(habit.id!), habit.completionsPerDay);
      if (streak > best) best = streak;
    }
    return best;
  }

  void _showHabitMenu(BuildContext context, Habit habit, HabitProvider provider, HabitLogProvider logProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2))),
          ListTile(leading: const Icon(Icons.edit, color: Colors.blueAccent), title: Text("Edit Habit", style: TextStyle(color: textColor)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit))); }),
          ListTile(leading: const Icon(Icons.archive_outlined, color: Colors.orangeAccent), title: Text("Archive Habit", style: TextStyle(color: textColor)), onTap: () { Navigator.pop(context); provider.archiveHabit(habit.id!); }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
