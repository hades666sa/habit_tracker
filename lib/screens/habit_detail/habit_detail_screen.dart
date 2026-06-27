import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/habit_log_provider.dart';
import '../../data/models/habit.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../utils/color_utils.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late String _selectedColor;
  late String _selectedIcon;
  final Set<String> _selectedCategories = {'Other'};
  int _completionsPerDay = 1;
  String _frequency = 'DAILY';
  String? _frequencyDays;
  int _streakGoal = 0;
  String _alarmSound = 'Default';
  String? _reminderTime;

  final List<String> _sounds = ['Default', 'Elegant', 'Bright', 'Nature', 'Pulse', 'Zen'];
  final List<String> _quickIcons = ['🎨', '🏈', '🏆', '🥇', '🏀', '⭐'];
  final List<Color> _quickColors = [
    const Color(0xFFFFF9C4), const Color(0xFFFFCC80), const Color(0xFFA1887F), const Color(0xFFBCAAA4), const Color(0xFFFF8A80), const Color(0xFFC5CAE9),
    const Color(0xFFFFCDD2), const Color(0xFFF48FB1), const Color(0xFFF8BBD0), const Color(0xFFCE93D8), const Color(0xFFB2DFDB), const Color(0xFFB2EBF2), const Color(0xFFC8E6C9),
    const Color(0xFF81C784), const Color(0xFF4FC3F7), const Color(0xFF9575CD)
  ];

  final List<Map<String, dynamic>> _categories = [
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
    _selectedCategories.clear();
    _selectedCategories.addAll(widget.habit.category.split(', ').where((c) => c.isNotEmpty));
    if (_selectedCategories.isEmpty) _selectedCategories.add('Other');
    _streakGoal = widget.habit.streakGoal;
    _alarmSound = widget.habit.alarmSound;
    _reminderTime = widget.habit.reminderTime;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return WillPopScope(
      onWillPop: () async {
        await _performSave();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: Text(widget.habit.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Habit Name", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : Colors.black54)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor, fontSize: 18),
              decoration: InputDecoration(
                hintText: "E.g. Morning Yoga",
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            Text("Description", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : Colors.black54)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Optional",
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            Text("Icon", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : Colors.black54)),
            const SizedBox(height: 16),
            _buildIconPicker(),
            const SizedBox(height: 24),

            Text("Color", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : Colors.black54)),
            const SizedBox(height: 16),
            _buildColorPicker(),
            const SizedBox(height: 32),

            Text("Goal Per Day", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : Colors.black54)),
            const SizedBox(height: 8),
            _buildCompletionsControl(isDark),
            const SizedBox(height: 32),

            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: _buildExpansionTile(
                title: "Advanced Options",
                isDark: isDark,
                children: [
                  _buildOptionTile("Streak Goal", _streakGoal == 0 ? "None" : "$_streakGoal Days", isDark: isDark, onTap: _showStreakGoalPicker),
                  _buildOptionTile("Frequency", _frequency, isDark: isDark, onTap: _showFrequencyPicker),
                  _buildOptionTile("Reminder", _reminderTime ?? "OFF", isDark: isDark, onTap: _showReminderPicker),
                  _buildOptionTile("Alarm", _alarmSound, isDark: isDark, onTap: _showAlarmPicker),
                  _buildOptionTile("Categories", _selectedCategories.isEmpty ? 'None' : _selectedCategories.join(', '), isDark: isDark, onTap: _showCategoryPicker),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: _confirmDelete, child: const Text("Delete Habit", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    ));
  }
  
  Future<void> _performSave() async {
    if (_nameController.text.isEmpty) return;
    
    try {
      final updatedHabit = widget.habit.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        icon: _selectedIcon,
        color: _selectedColor,
        category: _selectedCategories.isEmpty ? 'Other' : _selectedCategories.join(', '),
        completionsPerDay: _completionsPerDay,
        frequency: _frequency,
        frequencyDays: _frequencyDays,
        streakGoal: _streakGoal,
        alarmSound: _alarmSound,
        reminderTime: _reminderTime,
      );
      
      await Provider.of<HabitProvider>(context, listen: false).updateHabit(updatedHabit);

      if (!mounted) return;
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      if (settingsProvider.widgetHabitIds.contains(updatedHabit.id)) {
        final logProvider = Provider.of<HabitLogProvider>(context, listen: false);
        final allLogs = logProvider.getCompletionsForHabit(updatedHabit.id!);
        await settingsProvider.updateWidgetForHabit(updatedHabit, allLogs);
      }
    } catch (e) {
      debugPrint("Error performing save: $e");
    }
  }

  void _showColorPicker() {
    Color currentColor = _selectedColor.toHabitColor();
    showDialog(context: context, builder: (BuildContext context) => AlertDialog(title: const Text('Pick a color'), content: SingleChildScrollView(child: ColorPicker(pickerColor: currentColor, onColorChanged: (Color color) => setState(() => _selectedColor = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}'), pickerAreaHeightPercent: 0.8)), actions: [TextButton(child: const Text('Done'), onPressed: () => Navigator.pop(context))]));
  }

  Widget _buildIconPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(spacing: 12, runSpacing: 12, children: [
      if (!_quickIcons.contains(_selectedIcon)) Container(width: 55, height: 55, decoration: BoxDecoration(color: Colors.indigoAccent.withOpacity(0.8), borderRadius: BorderRadius.circular(15)), child: Center(child: Text(_selectedIcon, style: const TextStyle(fontSize: 28)))),
      ..._quickIcons.map((icon) {
        final isSelected = _selectedIcon == icon;
        return GestureDetector(onTap: () => setState(() => _selectedIcon = icon), child: Container(width: 55, height: 55, decoration: BoxDecoration(color: isSelected ? Colors.indigoAccent.withOpacity(0.8) : Colors.transparent, borderRadius: BorderRadius.circular(15), border: isSelected ? null : Border.all(color: isDark ? Colors.white10 : Colors.black12)), child: Center(child: Text(icon, style: const TextStyle(fontSize: 28)))));
      }),
      GestureDetector(onTap: _showEmojiPicker, child: Container(width: 55, height: 55, decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.add, color: isDark ? Colors.white70 : Colors.black45))),
    ]);
  }

  void _showEmojiPicker() {
    showModalBottomSheet(context: context, builder: (context) => SizedBox(height: 300, child: EmojiPicker(onEmojiSelected: (category, emoji) { setState(() => _selectedIcon = emoji.emoji); Navigator.pop(context); })));
  }

  Widget _buildColorPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(spacing: 12, runSpacing: 12, children: [
      if (!_quickColors.any((c) => '#${c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}' == _selectedColor)) Container(width: 45, height: 45, decoration: BoxDecoration(color: _selectedColor.toHabitColor(), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
      ..._quickColors.map((color) {
        final colorHex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
        final isSelected = _selectedColor == colorHex;
        return GestureDetector(onTap: () => setState(() => _selectedColor = colorHex), child: Container(width: 45, height: 45, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: isSelected ? Border.all(color: isDark ? Colors.white : Colors.black87, width: 2) : null)));
      }),
      GestureDetector(onTap: _showColorPicker, child: Container(width: 45, height: 45, decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), shape: BoxShape.circle), child: Icon(Icons.colorize, size: 20, color: isDark ? Colors.white70 : Colors.black45))),
    ]);
  }

  Widget _buildExpansionTile({required String title, required List<Widget> children, required bool isDark}) => ExpansionTile(title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)), childrenPadding: const EdgeInsets.symmetric(horizontal: 16), children: children);

  Widget _buildOptionTile(String title, String value, {required bool isDark, VoidCallback? onTap}) => ListTile(title: Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)), trailing: Text(value, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)), onTap: onTap);

  Widget _buildCompletionsControl(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Target Completions",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () { if (_completionsPerDay > 1) setState(() => _completionsPerDay--); }, icon: const Icon(Icons.remove_circle_outline)),
              SizedBox(
                width: 24,
                child: Center(
                  child: Text(
                    "$_completionsPerDay",
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(onPressed: () => setState(() => _completionsPerDay++), icon: const Icon(Icons.add_circle_outline)),
            ],
          ),
        ],
      ),
    );
  }

  void _showStreakGoalPicker() => showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Streak Goal"), content: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Enter number of days"), onSubmitted: (val) { setState(() => _streakGoal = int.tryParse(val) ?? 0); Navigator.pop(context); })));

  void _showFrequencyPicker() {
    final List<String> frequencies = ['DAILY', 'WEEKLY', 'MONTHLY'];
    showModalBottomSheet(context: context, builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: frequencies.map((f) => ListTile(title: Text(f), onTap: () { setState(() => _frequency = f); Navigator.pop(context); })).toList()));
  }

  void _showReminderPicker() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) setState(() => _reminderTime = time.format(context));
  }

  void _showAlarmPicker() => showModalBottomSheet(context: context, builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: _sounds.map((s) => ListTile(title: Text(s), onTap: () { setState(() => _alarmSound = s); Navigator.pop(context); })).toList()));

  void _showCategoryPicker() => showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(title: const Text("Select Categories"), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: _categories.map((cat) { final isSelected = _selectedCategories.contains(cat['name']); return CheckboxListTile(title: Text(cat['name']), value: isSelected, onChanged: (val) { setDialogState(() { if (val == true) {
    _selectedCategories.add(cat['name']);
  } else if (_selectedCategories.length > 1) _selectedCategories.remove(cat['name']); }); setState(() {}); }); }).toList())), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Done"))])));

  void _confirmDelete() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: Theme.of(context).cardColor, title: Text("Delete Habit?", style: TextStyle(color: isDark ? Colors.white : Colors.black87)), content: Text("This will permanently remove this habit and all its history. This cannot be undone.", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)), actions: [TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)), TextButton(child: const Text("Delete", style: TextStyle(color: Colors.redAccent)), onPressed: () { Provider.of<HabitProvider>(context, listen: false).deleteHabit(widget.habit.id!); Navigator.pop(context); Navigator.pop(context); })]));
  }

  void _saveHabit() async {
    await _performSave();
    if (mounted) {
      Navigator.maybePop(context);
    }
  }
}
