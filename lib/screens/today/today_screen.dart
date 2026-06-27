import '../create_habit/create_habit_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/widget_image_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/habit_log_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../utils/date_utils.dart';
import '../../data/models/habit.dart';
import '../habit_detail/habit_detail_screen.dart';
import '../../widgets/habit_card.dart';
import 'widgets/date_scroller_widget.dart';
import 'widgets/category_filter_widget.dart';
import 'widgets/segmented_control_widget.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'All';
  bool _isReorderMode = false;
  String _viewMode = 'Today';
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view},
    {'name': 'Art', 'icon': Icons.palette},
    {'name': 'Finances', 'icon': Icons.attach_money},
    {'name': 'Fitness', 'icon': Icons.directions_run},
    {'name': 'Health', 'icon': Icons.favorite_border},
    {'name': 'Nutrition', 'icon': Icons.restaurant},
    {'name': 'Social', 'icon': Icons.group},
    {'name': 'Study', 'icon': Icons.school},
    {'name': 'Work', 'icon': Icons.work_outline},
    {'name': 'Other', 'icon': Icons.layers_outlined},
    {'name': 'Morning', 'icon': Icons.wb_sunny_outlined},
    {'name': 'Day', 'icon': Icons.wb_twilight},
    {'name': 'Evening', 'icon': Icons.dark_mode_outlined},
  ];

  bool _streaksLoaded = false;

  @override
  void didChangeDependencies() {
     super.didChangeDependencies();
     if (!_streaksLoaded) {
       final habitProvider = Provider.of<HabitProvider>(context);
       final logProvider = Provider.of<HabitLogProvider>(context, listen: false);
       if (habitProvider.habits.isNotEmpty) {
           _streaksLoaded = true;
           final targets = { for (var h in habitProvider.habits) h.id!: h.completionsPerDay };
           logProvider.calculateAllStreaks(targets);
       }
     }
  }

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
        title: Text("Home", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, shape: BoxShape.circle),
               child: Icon(Icons.calendar_today, color: textColor, size: 18),
            ),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
          ),
          if (_isReorderMode)
            TextButton(
              onPressed: () => setState(() => _isReorderMode = false),
              child: const Text("Done", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Consumer3<HabitProvider, HabitLogProvider, SettingsProvider>(
        builder: (context, habitProvider, logProvider, settingsProvider, _) {
          return Column(
            children: [
              const SizedBox(height: 16),
              SegmentedControlWidget(
                viewMode: _viewMode,
                onViewModeChanged: (mode) {
                  setState(() {
                    _viewMode = mode;
                    if (mode == 'Today') {
                      _selectedDate = DateTime.now();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              DateScrollerWidget(
                selectedDate: _selectedDate,
                onDateSelected: (date) => setState(() => _selectedDate = date),
                settings: settingsProvider,
              ),
              const SizedBox(height: 16),
              if (settingsProvider.showCategoryFilter) ...[
                CategoryFilterWidget(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
                  categories: _categories,
                ),
                const SizedBox(height: 8),
              ],
              Expanded(
                child: _buildUnifiedHabitList(isDark, textColor, habitProvider, logProvider, settingsProvider),
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

  Widget _buildUnifiedHabitList(bool isDark, Color textColor, HabitProvider habitProvider, HabitLogProvider logProvider, SettingsProvider settingsProvider) {
    final habits = habitProvider.habits.where((h) {
       if (_selectedCategory != 'All' && !h.category.contains(_selectedCategory)) return false;
       if (h.frequency == 'DAILY') return true;
       if (h.frequency == 'WEEKLY') return true;
       if (h.frequency == 'ONE_TIME') {
         return h.frequencyDays == AppDateUtils.formatDate(_selectedDate);
       }
       return false;
    }).toList();

    if (habits.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(radius: 50, backgroundColor: isDark ? const Color(0xFF1C1F22) : Colors.black.withOpacity(0.05), child: const Text('🌱', style: TextStyle(fontSize: 40))),
        const SizedBox(height: 24),
        Text("Time to Grow!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 8),
        const Text("No habits scheduled for today.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
      ]));
    }

    if (_isReorderMode) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: habits.length,
        onReorder: (oldIndex, newIndex) => habitProvider.reorderHabits(oldIndex, newIndex, habits),
        itemBuilder: (context, index) {
          final habit = habits[index];
          final logs = logProvider.getCompletionsForHabit(habit.id!);
          final streak = logProvider.getStreak(habit.id!);
          return HabitCard(
            key: ValueKey(habit.id),
            index: index,
            isReorderMode: true,
            habit: habit,
            streak: streak,
            selectedDate: _selectedDate,
            isCompleted: logProvider.isCompleted(habit.id!, AppDateUtils.formatDate(_selectedDate), habit.completionsPerDay),
            completedDates: logs,
            viewMode: _viewMode,
            onToggle: () {}, 
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        final logs = logProvider.getCompletionsForHabit(habit.id!);
        final streak = logProvider.getStreak(habit.id!);
        return HabitCard(
          key: ValueKey(habit.id),
          index: index,
          isReorderMode: false,
          habit: habit,
          streak: streak,
          selectedDate: _selectedDate,
          isCompleted: logProvider.isCompleted(habit.id!, AppDateUtils.formatDate(_selectedDate), habit.completionsPerDay),
          completedDates: logs,
          viewMode: _viewMode,
          onToggle: () async {
              if (!AppDateUtils.isSameDay(_selectedDate, DateTime.now())) {
                return;
              }

              final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
              final habitProviderLocal = Provider.of<HabitProvider>(context, listen: false);
              
              await logProvider.toggleCompletion(habit.id!, AppDateUtils.formatDate(_selectedDate), habit.completionsPerDay);
              
              if (!mounted) return;
              
              if (settingsProvider.widgetHabitIds.contains(habit.id)) {
                final allLogs = logProvider.getCompletionsForHabit(habit.id!);
                settingsProvider.updateWidgetForHabit(habit, allLogs);
              }

              final targetCounts = { for (var h in habitProviderLocal.habits) h.id!: h.completionsPerDay };
              achievementProvider.checkAchievements(logProvider.habitCompletions, targetCounts);
          },
          onLongPress: () => _showHabitMenu(context, habit, habitProvider, logProvider),
        );
      },
    );
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
          ListTile(leading: const Icon(Icons.reorder, color: Colors.blueAccent), title: Text("Reorder Habits", style: TextStyle(color: textColor)), onTap: () { Navigator.pop(context); setState(() => _isReorderMode = true); }),
          ListTile(leading: const Icon(Icons.share, color: Colors.greenAccent), title: Text("Share Achievement", style: TextStyle(color: textColor)), onTap: () async {
            Navigator.pop(context);
            final streak = logProvider.getStreak(habit.id!);
            final text = "I'm on a $streak-day streak for ${habit.name} on HabitLoop! Can you beat my streak?";
            try {
              final tempDir = await getTemporaryDirectory();
              final allLogs = logProvider.getCompletionsForHabit(habit.id!);
              final data = HeatmapGenerationData(
                habit: habit,
                logs: allLogs,
                columns: 52,
                rows: 7,
                sizeKey: 'share_${habit.id}',
                themeStr: isDark ? 'dark' : 'light',
                tempDirPath: tempDir.path,
              );
              final path = await generateHeatmapImageIsolated(data);
              if (path != null) {
                await Share.shareXFiles([XFile(path)], text: text);
              } else {
                Share.share(text);
              }
            } catch (e) {
              Share.share(text);
            }
          }),
          ListTile(leading: const Icon(Icons.archive_outlined, color: Colors.orangeAccent), title: Text("Archive Habit", style: TextStyle(color: textColor)), onTap: () { Navigator.pop(context); provider.archiveHabit(habit.id!); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${habit.name} archived"), action: SnackBarAction(label: "Undo", onPressed: () => provider.unarchiveHabit(habit.id!)))); }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
