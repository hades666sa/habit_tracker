import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../data/models/habit.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, _) {
        final archivedHabits = habitProvider.archivedHabits;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black87;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text("Archived Habits", 
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          body: archivedHabits.isEmpty
              ? _buildEmptyState(context, isDark)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: archivedHabits.length,
                  itemBuilder: (context, index) {
                    final habit = archivedHabits[index];
                    return _buildArchivedHabitCard(context, habit, habitProvider, isDark);
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.archive_outlined, size: 80, color: isDark ? Colors.white10 : Colors.black12),
          const SizedBox(height: 16),
          Text("No archived habits", 
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildArchivedHabitCard(BuildContext context, Habit habit, HabitProvider provider, bool isDark) {
    final habitColor = habit.parsedColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Text(habit.icon, style: TextStyle(fontSize: 28, color: habitColor)),
            title: Text(habit.name, 
              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text(habit.category, 
              style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 14)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings_backup_restore, color: Colors.blueAccent),
                  onPressed: () => _showRestoreDialog(context, habit, provider),
                  tooltip: 'Restore',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _showDeleteDialog(context, habit, provider),
                  tooltip: 'Delete Permanently',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, Habit habit, HabitProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Restore Habit?"),
        content: Text("Do you want to restore '${habit.name}' to your active habits?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              provider.unarchiveHabit(habit.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("'${habit.name}' restored"), backgroundColor: Colors.blueAccent),
              );
            },
            child: const Text("Restore", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Habit habit, HabitProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Permanently?"),
        content: Text("This will permanently delete '${habit.name}' and all its history. This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              provider.deleteHabit(habit.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Habit deleted"), backgroundColor: Colors.redAccent),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}