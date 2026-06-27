import re

with open('c:/Users/hp/.antigravity/habitloop/lib/screens/create_habit/create_habit_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Replace class names
code = code.replace('CreateHabitScreen', 'HabitDetailScreen')

# Import HabitLogProvider (create_habit_screen doesn't have it, but we might need it for Consumer if it was used, but wait, create_habit_screen doesn't use it. HabitDetailScreen did use Consumer<HabitLogProvider>, but we can just skip it if we don't need it. Actually HabitDetailScreen had it just to maybe show completions, but the old body didn't even use logProvider. So we can just use the create_habit_screen body)

# Add habit parameter
code = code.replace('const HabitDetailScreen({super.key});', 'final Habit habit;\n  const HabitDetailScreen({super.key, required this.habit});')

# Replace _selectedIcon and _selectedColor initializers
code = re.sub(r'String _selectedIcon = \'[^\']+\';', 'late String _selectedIcon;', code)
code = re.sub(r'String _selectedColor = \'[^\']+\';', 'late String _selectedColor;', code)

# Add initState
init_state_code = '''
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.habit.name;
    _descriptionController.text = widget.habit.description;
    _selectedIcon = widget.habit.icon;
    _selectedColor = widget.habit.color;
    _completionsPerDay = widget.habit.completionsPerDay;
    _frequency = widget.habit.frequency;
    _frequencyDays = widget.habit.frequencyDays;
    _selectedCategories = widget.habit.category.split(', ').where((c) => c.isNotEmpty).toSet();
    _streakGoal = widget.habit.streakGoal;
    _alarmSound = widget.habit.alarmSound;
    _reminderTime = widget.habit.reminderTime;

    if (_frequency == 'ONE_TIME') {
      _isOneTime = true;
      if (_frequencyDays != null) {
        try {
          _oneTimeDate = DateTime.parse(_frequencyDays!);
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {'''
code = code.replace('  @override\n  void dispose() {', init_state_code)

# AppBar title
code = re.sub(r'title: const Text\(\s*"Create Habit",', 'title: const Text(\n          "Edit Habit",', code)

# Bottom Nav Bar Button Text
code = re.sub(r'child: const Text\(\s*"Create Habit",', 'child: const Text(\n            "Save Changes",', code)

# Delete Button
delete_btn_code = '''
            const SizedBox(height: 48),
            Center(
              child: TextButton.icon(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                label: const Text("Delete Habit", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.redAccent.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
'''
code = code.replace('            const SizedBox(height: 48),\n          ],\n', delete_btn_code)

# Add _confirmDelete
confirm_delete_code = '''
  void _confirmDelete() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text("Delete Habit?", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Text("This will permanently remove this habit and all its history. This cannot be undone.", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Provider.of<HabitProvider>(context, listen: false).deleteHabit(widget.habit.id!);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
            },
          ),
        ],
      ),
    );
  }

  void _showIconPicker() {'''
code = code.replace('  void _showIconPicker() {', confirm_delete_code)

# Update _saveHabit
save_habit_code = '''  void _saveHabit() {
    if (_nameController.text.isEmpty) return;
    
    String finalFrequency = _isOneTime ? 'ONE_TIME' : _frequency;
    String? finalFrequencyDays = _isOneTime ? (_oneTimeDate != null ? AppDateUtils.formatDate(_oneTimeDate!) : AppDateUtils.formatDate(DateTime.now())) : _frequencyDays;

    final updatedHabit = widget.habit.copyWith(
      name: _nameController.text,
      description: _descriptionController.text,
      icon: _selectedIcon,
      color: _selectedColor,
      category: _selectedCategories.isEmpty ? 'Other' : _selectedCategories.join(', '),
      completionsPerDay: _completionsPerDay,
      frequency: finalFrequency,
      frequencyDays: finalFrequencyDays,
      streakGoal: _streakGoal,
      alarmSound: _alarmSound,
      reminderTime: _reminderTime,
    );
    Provider.of<HabitProvider>(context, listen: false).updateHabit(updatedHabit);
    Navigator.pop(context);
  }'''
code = re.sub(r'  void _saveHabit\(\) \{[\s\S]*?\}', save_habit_code, code)

with open('c:/Users/hp/.antigravity/habitloop/lib/screens/habit_detail/habit_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)

print("Done generating habit_detail_screen.dart")
