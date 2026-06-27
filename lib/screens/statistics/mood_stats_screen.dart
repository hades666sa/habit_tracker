import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/mood_provider.dart';
import '../../utils/date_utils.dart';
import '../../data/models/mood_entry.dart';

class MoodStatsScreen extends StatefulWidget {
  const MoodStatsScreen({super.key});

  @override
  State<MoodStatsScreen> createState() => _MoodStatsScreenState();
}

class _MoodStatsScreenState extends State<MoodStatsScreen> {
  DateTime _focusedMonth = DateTime.now();
  bool _showHistory = false;

  final Map<String, String> _moodIcons = {
    'Great': '😎',
    'Good': '😊',
    'Okay': '😐',
    'Not Good': '🙁',
    'Bad': '😡',
  };

  final List<String> _feelingTags = [
    'Happy', 'Brave', 'Motivated', 'Creative', 'Confident', 'Calm',
    'Grateful', 'Peaceful', 'Excited', 'Loved', 'Hopeful', 'Inspired',
    'Proud', 'Euphoric', 'Nostalgic'
  ];

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: _showHistory 
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => setState(() => _showHistory = false),
            )
          : IconButton(
              icon: Icon(Icons.menu, color: textColor),
              onPressed: () {
                // Find the root scaffold (MainShell) to open its drawer
                Scaffold.of(context).openDrawer();
              },
            ),
        title: Text(
          _showHistory ? "Mood History" : "Mood Stat",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          if (!_showHistory)
            IconButton(
              icon: Icon(Icons.history, color: textColor),
              onPressed: () => setState(() => _showHistory = true),
            ),
        ],
      ),
      body: _showHistory 
        ? _buildHistoryList(moodProvider, textColor, isDark)
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1F22) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildCalendarView(moodProvider, textColor, isDark),
            ),
          ),
    );
  }

  Widget _buildCalendarView(MoodProvider provider, Color textColor, bool isDark) {
    return Column(
      children: [
        // Month Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, size: 20, color: isDark ? Colors.white70 : Colors.black87),
                onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 20, color: isDark ? Colors.white70 : Colors.black87),
                onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
              ),
            ],
          ),
        ),
        
        // Weekdays
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                .map((day) => Text(day, style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 14)))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        
        // Calendar Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 12,
              crossAxisSpacing: 4,
              childAspectRatio: 0.5, // Even taller to fix overflow
            ),
            itemCount: _daysInMonth(_focusedMonth) + _firstWeekdayOfMonth(_focusedMonth),
            itemBuilder: (context, index) {
              final firstWeekday = _firstWeekdayOfMonth(_focusedMonth);
              if (index < firstWeekday) return const SizedBox();
              
              final day = index - firstWeekday + 1;
              final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final dateStr = AppDateUtils.formatDate(date);
              final entry = provider.getMoodForDate(dateStr);
              final isToday = AppDateUtils.isSameDay(date, DateTime.now());

              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  children: [
                    if (entry != null) ...[
                      Text(_moodIcons[entry.mood] ?? '😐', style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(entry.mood, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600)),
                    ] else if (isToday) ...[
                      GestureDetector(
                        onTap: () => _showMoodEntrySheet(context),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, size: 16, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text("Today", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600)),
                    ] else ...[
                      Icon(Icons.sentiment_neutral_outlined, size: 20, color: isDark ? Colors.white10 : Colors.black12),
                      const SizedBox(height: 4),
                      Text("Mood", style: TextStyle(fontSize: 9, color: isDark ? Colors.white10 : Colors.black12)),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      "$day",
                      style: TextStyle(
                        fontSize: 12,
                        color: isToday ? (isDark ? Colors.blue : Colors.black) : (entry != null ? Colors.grey : textColor),
                        fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(MoodProvider provider, Color textColor, bool isDark) {
    if (provider.moods.isEmpty) {
      return Center(child: Text("No mood entries yet", style: TextStyle(color: textColor.withOpacity(0.5))));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.moods.length,
      itemBuilder: (context, index) {
        final entry = provider.moods[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(_moodIcons[entry.mood] ?? '😐', style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${entry.mood}${entry.feeling != null ? ' • ${entry.feeling}' : ''}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(entry.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _daysInMonth(DateTime date) => DateTime(date.year, date.month + 1, 0).day;
  int _firstWeekdayOfMonth(DateTime date) => DateTime(date.year, date.month, 1).weekday - 1;

  void _showMoodEntrySheet(BuildContext context) {
    String? selectedMood;
    String? selectedFeeling;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final bgColor = isDark ? const Color(0xFF1C1F22) : Colors.white;

          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 24),
                  if (selectedMood == null) ...[
                    const Text("How is your mood today?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _moodIcons.entries.map((e) => GestureDetector(
                        onTap: () => setSheetState(() => selectedMood = e.key),
                        child: Column(
                          children: [
                            Text(e.value, style: const TextStyle(fontSize: 40)),
                            const SizedBox(height: 8),
                            Text(e.key, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 40),
                  ] else ...[
                    Text("$selectedMood! How would you describe\nyour feelings?", 
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _feelingTags.map((tag) => ChoiceChip(
                        label: Text(tag),
                        selected: selectedFeeling == tag,
                        onSelected: (val) => setSheetState(() => selectedFeeling = val ? tag : null),
                        selectedColor: Colors.blue.withOpacity(0.3),
                        labelStyle: TextStyle(color: selectedFeeling == tag ? Colors.blue : Colors.grey),
                      )).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Provider.of<MoodProvider>(context, listen: false).saveMood(selectedMood!, selectedFeeling);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text("I Feel ${selectedFeeling ?? selectedMood}!", style: const TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
