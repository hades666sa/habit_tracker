import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../data/models/habit.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../utils/date_utils.dart';
import '../../utils/color_utils.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedColor = '#43A047';
  String _selectedIcon = '🧘';
  final Set<String> _selectedCategories = {'Other'};
  int _completionsPerDay = 1;
  String _frequency = 'DAILY';
  String? _frequencyDays;
  int _streakGoal = 0;
  String _alarmSound = 'Default';
  String? _reminderTime;

  bool _isOneTime = false;
  DateTime? _oneTimeDate;

  final List<String> _sounds = [
    'Default',
    'Elegant',
    'Bright',
    'Nature',
    'Pulse',
    'Zen',
  ];

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
  Widget build(BuildContext context) {
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
        title: Text(
          "Create Habit",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isOneTime = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isOneTime ? Colors.indigoAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "Regular Habit",
                            style: TextStyle(
                              color: !_isOneTime ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isOneTime = true;
                        _oneTimeDate ??= DateTime.now();
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isOneTime ? Colors.indigoAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "One-Time",
                            style: TextStyle(
                              color: _isOneTime ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Habit Name Entry Space (Extra Option)
            Text(
              "Habit Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "e.g. Morning Yoga",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              "Description",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: "Add a description (optional)",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                ),
                maxLines: null,
                style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              "Icon",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            _buildIconPicker(),
            const SizedBox(height: 32),

            Text(
              "Color",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            _buildColorPicker(),
            const SizedBox(height: 32),

            Text(
              "Times Per Day",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            _buildCompletionsControl(isDark),
            const SizedBox(height: 32),

            if (_isOneTime)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Date",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _oneTimeDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        setState(() => _oneTimeDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _oneTimeDate != null ? AppDateUtils.formatDate(_oneTimeDate!) : "Choose Date",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          Icon(Icons.calendar_today, color: isDark ? Colors.white54 : Colors.black54),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),

            if (!_isOneTime)
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: _buildExpansionTile(
                title: "Advanced Options",
                isDark: isDark,
                children: [
                  _buildOptionTile(
                    "Streak Goal",
                    _streakGoal == 0 ? "None" : "$_streakGoal Days",
                    isDark: isDark,
                    onTap: _showStreakGoalPicker,
                  ),
                  _buildOptionTile(
                    "Frequency",
                    _frequency,
                    isDark: isDark,
                    onTap: _showFrequencyPicker,
                  ),
                  _buildOptionTile(
                    "Reminder",
                    _reminderTime ?? "OFF",
                    isDark: isDark,
                    onTap: _showReminderPicker,
                  ),
                  _buildOptionTile(
                    "Alarm",
                    _alarmSound,
                    isDark: isDark,
                    onTap: _showAlarmPicker,
                  ),
                  _buildOptionTile(
                    "Categories",
                    _selectedCategories.isEmpty
                        ? 'None'
                        : _selectedCategories.join(', '),
                    isDark: isDark,
                    onTap: _showCategoryPicker,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: _saveHabit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            "Create Habit",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Select Icon", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: EmojiPicker(
                  onEmojiSelected: (Category? category, Emoji emoji) {
                    setState(() {
                      _selectedIcon = emoji.emoji;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorPicker() {
    Color currentColor = _selectedColor.toHabitColor();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (!_quickIcons.contains(_selectedIcon))
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.indigoAccent.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(_selectedIcon, style: const TextStyle(fontSize: 28)),
            ),
          ),
        ..._quickIcons.map((icon) {
          final isSelected = _selectedIcon == icon;
          return GestureDetector(
            onTap: () => setState(() => _selectedIcon = icon),
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: isSelected ? Colors.indigoAccent.withOpacity(0.8) : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: isSelected ? null : Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 28)),
              ),
            ),
          );
        }),
        GestureDetector(
          onTap: _showIconPicker,
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Center(
              child: Icon(Icons.add, color: isDark ? Colors.white54 : Colors.black54, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ..._quickColors.map((color) {
          final hex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
          final isSelected = _selectedColor == hex;
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = hex),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.black54) : null,
            ),
          );
        }),
        GestureDetector(
          onTap: _showColorPicker,
          child: Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.indigo, Colors.purple, Colors.red],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required List<Widget> children,
    required bool isDark,
  }) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      iconColor: Colors.grey,
      collapsedIconColor: Colors.grey,
      children: children,
    );
  }

  Widget _buildOptionTile(
    String label,
    String value, {
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Colors.grey)),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        ],
      ),
      onTap: onTap ?? () {},
    );
  }

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
              _buildActionBtn(Icons.remove, () {
                if (_completionsPerDay > 1) setState(() => _completionsPerDay--);
              }, isDark),
              const SizedBox(width: 16),
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
              const SizedBox(width: 16),
              _buildActionBtn(
                Icons.add,
                () => setState(() => _completionsPerDay++),
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blueAccent, size: 18),
      ),
    );
  }

  void _showStreakGoalPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Streak Goal",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [7, 14, 21, 30, 60, 90, 0].map((days) {
                final isSelected = _streakGoal == days;
                return ChoiceChip(
                  label: Text(days == 0 ? "No Goal" : "$days Days"),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() => _streakGoal = days);
                    Navigator.pop(context);
                  },
                  selectedColor: Colors.blueAccent,
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showReminderPicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(
        () => _reminderTime =
            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
      );
    }
  }

  void _showAlarmPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                "Select Sound",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ..._sounds.map(
                (s) => ListTile(
                  title: Text(
                    s,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: _alarmSound == s
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: _alarmSound == s
                      ? const Icon(Icons.check, color: Colors.blueAccent)
                      : null,
                  onTap: () {
                    setState(() => _alarmSound = s);
                    FlutterRingtonePlayer().playRingtone();
                    Future.delayed(
                      const Duration(seconds: 2),
                      () => FlutterRingtonePlayer().stop(),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(
                  Icons.library_music,
                  color: Colors.blueAccent,
                ),
                title: Text(
                  "Pick from Device Storage",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.audio,
                    );
                    if (result != null) {
                      setState(() => _alarmSound = result.files.single.name);
                    }
                  } catch (e) {
                    debugPrint("File picking failed: $e");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Categories",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final name = cat['name'] as String;
                    final icon = cat['icon'] as IconData;
                    final isSelected = _selectedCategories.contains(name);
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          if (isSelected) {
                            _selectedCategories.remove(name);
                          } else {
                            _selectedCategories.add(name);
                          }
                        });
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : (isDark ? Colors.white10 : Colors.black12),
                          ),
                          color: isSelected
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              size: 18,
                              color: isSelected
                                  ? Colors.blue
                                  : (isDark ? Colors.white60 : Colors.black54),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: isSelected
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : (isDark
                                            ? Colors.white60
                                            : Colors.black54),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setModalState(() => _selectedCategories.clear());
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text("Clear All"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    side: BorderSide(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFrequencyPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Repetition",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: ['DAILY', 'WEEKLY'].map((freq) {
                  final isSelected = _frequency == freq;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(freq),
                        selected: isSelected,
                        onSelected: (val) {
                          setModalState(() {
                            _frequency = freq;
                            if (freq == 'WEEKLY' && _frequencyDays == null) {
                              _frequencyDays = '1,2,3,4,5,6,7';
                            }
                          });
                          setState(() {});
                        },
                        selectedColor: Colors.blueAccent.withOpacity(0.2),
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.blueAccent
                              : (isDark ? Colors.white70 : Colors.black54),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.blueAccent
                                : (isDark ? Colors.white10 : Colors.black12),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_frequency == 'WEEKLY') ...[
                const SizedBox(height: 16),
                const Text(
                  "SELECT DAYS",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                _buildWeeklyDayPickerModal(isDark, setModalState),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyDayPickerModal(bool isDark, StateSetter setModalState) {
    final days = ["M", "T", "W", "T", "F", "S", "S"];
    final selectedDays =
        _frequencyDays?.split(',').map(int.parse).toSet() ??
        {1, 2, 3, 4, 5, 6, 7};
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final dayNum = index + 1;
        final isSelected = selectedDays.contains(dayNum);
        return GestureDetector(
          onTap: () {
            setModalState(() {
              if (isSelected && selectedDays.length > 1) {
                selectedDays.remove(dayNum);
              } else {
                selectedDays.add(dayNum);
              }
              final dayList = selectedDays.toList()..sort();
              _frequencyDays = dayList.join(',');
            });
            setState(() {});
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blueAccent
                  : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              days[index],
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  void _saveHabit() {
    if (_nameController.text.isEmpty) return;
    
    String finalFrequency = _isOneTime ? 'ONE_TIME' : _frequency;
    String? finalFrequencyDays = _isOneTime ? (_oneTimeDate != null ? AppDateUtils.formatDate(_oneTimeDate!) : AppDateUtils.formatDate(DateTime.now())) : _frequencyDays;

    final habit = Habit(
      name: _nameController.text,
      description: _descriptionController.text,
      icon: _selectedIcon,
      color: _selectedColor,
      category: _selectedCategories.isEmpty
          ? 'Other'
          : _selectedCategories.join(', '),
      completionsPerDay: _completionsPerDay,
      frequency: finalFrequency,
      frequencyDays: finalFrequencyDays,
      createdAt: DateTime.now(),
      streakGoal: _streakGoal,
      alarmSound: _alarmSound,
      reminderTime: _reminderTime,
    );
    Provider.of<HabitProvider>(context, listen: false).addHabit(habit);
    Navigator.pop(context);
  }
}
