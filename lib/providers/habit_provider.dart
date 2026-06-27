import 'package:flutter/material.dart';
import '../data/models/habit.dart';
import '../data/repositories/habit_repository.dart';
import '../utils/notification_service.dart';

class HabitProvider with ChangeNotifier {
  final HabitRepository _repository;
  
  HabitProvider({HabitRepository? repository}) : _repository = repository ?? HabitRepository();
  
  List<Habit> _habits = [];
  List<Habit> _archivedHabits = [];

  List<Habit> get habits => _habits;
  List<Habit> get archivedHabits => _archivedHabits;
  
  Future<void> loadHabits() async {
    final allHabits = await _repository.getAll();
    _habits = allHabits.where((h) => h.isActive).toList();
    _archivedHabits = allHabits.where((h) => !h.isActive).toList();
    notifyListeners();
  }

  Future<void> archiveHabit(int id) async {
    Habit? habit;
    try {
      habit = _habits.firstWhere((h) => h.id == id);
    } catch (_) {
      try {
        habit = _archivedHabits.firstWhere((h) => h.id == id);
      } catch (_) {}
    }
    
    if (habit == null) {
      final allHabits = await _repository.getAll();
      habit = allHabits.firstWhere((h) => h.id == id);
    }
    
    await updateHabit(habit.copyWith(isActive: false));
  }

  Future<void> unarchiveHabit(int id) async {
    Habit? habit;
    try {
      habit = _archivedHabits.firstWhere((h) => h.id == id);
    } catch (_) {
      try {
        habit = _habits.firstWhere((h) => h.id == id);
      } catch (_) {}
    }
    
    if (habit == null) {
      final allHabits = await _repository.getAll();
      habit = allHabits.firstWhere((h) => h.id == id);
    }
    
    await updateHabit(habit.copyWith(isActive: true));
  }

  Future<Habit> addHabit(Habit habit) async {
    final id = await _repository.insert(habit);
    final insertedHabit = habit.copyWith(id: id);
    
    // Schedule reminder
    if (insertedHabit.reminderTime != null) {
      final parts = insertedHabit.reminderTime!.split(':');
      final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      await NotificationService.scheduleHabitReminder(
        habitId: insertedHabit.id!,
        habitName: insertedHabit.name,
        time: time,
      );
    }
    
    await loadHabits();
    return insertedHabit;
  }

  Future<void> updateHabit(Habit habit) async {
    await _repository.update(habit);
    
    // Reschedule reminder
    try {
      if (habit.id != null) {
        if (habit.reminderTime != null) {
          final parts = habit.reminderTime!.split(':');
          final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          await NotificationService.scheduleHabitReminder(
            habitId: habit.id!,
            habitName: habit.name,
            time: time,
          );
        } else {
          await NotificationService.cancelHabitReminder(habit.id!);
        }
      }
    } catch (e) {
      debugPrint("Failed to reschedule reminder: $e");
    }
    
    await loadHabits();
  }

  Future<void> deleteHabit(int id) async {
    await _repository.delete(id);
    await NotificationService.cancelHabitReminder(id);
    await loadHabits();
  }
  
  Future<void> reorderHabits(int oldIndex, int newIndex, List<Habit> currentViewHabits) async {
    if (newIndex > oldIndex) newIndex -= 1;
    
    final movedHabit = currentViewHabits[oldIndex];
    final targetHabit = currentViewHabits[newIndex];

    // Get global indices
    final globalOldIndex = _habits.indexWhere((h) => h.id == movedHabit.id);
    final globalNewIndex = _habits.indexWhere((h) => h.id == targetHabit.id);

    if (globalOldIndex == -1 || globalNewIndex == -1) return;

    final habit = _habits.removeAt(globalOldIndex);
    _habits.insert(globalNewIndex, habit);
    
    // Update sort order in DB only for affected active habits using batch update
    final updatedHabits = <Habit>[];
    final int start = globalOldIndex < globalNewIndex ? globalOldIndex : globalNewIndex;
    final int end = globalOldIndex > globalNewIndex ? globalOldIndex : globalNewIndex;

    for (int i = start; i <= end; i++) {
        final h = _habits[i].copyWith(sortOrder: i);
        _habits[i] = h; // Update in-memory as well
        updatedHabits.add(h);
    }
    
    if (updatedHabits.isNotEmpty) {
      await _repository.updateAll(updatedHabits);
    }
    notifyListeners();
  }
}
