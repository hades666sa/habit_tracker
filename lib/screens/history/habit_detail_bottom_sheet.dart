import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/habit.dart';
import '../../utils/date_utils.dart';
import '../../utils/streak_calculator.dart';
import '../habit_detail/habit_detail_screen.dart';

class HabitDetailBottomSheet extends StatefulWidget {
  final Habit habit;
  final Map<String, int> logs;

  const HabitDetailBottomSheet({
    super.key,
    required this.habit,
    required this.logs,
  });

  @override
  State<HabitDetailBottomSheet> createState() => _HabitDetailBottomSheetState();
}

class _HabitDetailBottomSheetState extends State<HabitDetailBottomSheet> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final habitColor = widget.habit.parsedColor;
    final currentStreak = StreakCalculator.currentStreak(widget.logs, widget.habit.completionsPerDay);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(widget.habit.icon, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.habit.name, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(widget.habit.description.isNotEmpty ? widget.habit.description : "No Description", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: isDark ? Colors.white54 : Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Compact Heatmap
          _buildCompactHeatmap(habitColor, isDark),
          const SizedBox(height: 24),

          // Streak Info Buttons + Edit Action
          Row(
            children: [
              _buildPillButton(
                context, 
                widget.habit.streakGoal > 0 ? "Goal: ${widget.habit.streakGoal}" : "No Streak Goal",
                isDark,
              ),
              const SizedBox(width: 12),
              _buildPillButton(
                context, 
                "$currentStreak",
                isDark,
                icon: Icons.local_fire_department,
                iconColor: Colors.orange,
              ),
              const Spacer(),
              _buildIconButton(
                context, 
                Icons.edit_note, 
                isDark,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: widget.habit)));
                },
              ),
              // Settings icon removed as per request
            ],
          ),
          const SizedBox(height: 32),

          // Monthly Calendar
          _buildWeekdayHeader(isDark),
          const SizedBox(height: 12),
          _buildMonthlyCalendar(habitColor, isDark),
          const SizedBox(height: 24),

          // Footer month selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, color: textColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM yyyy').format(_focusedMonth),
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildNavButton(context, Icons.chevron_left, _prevMonth, isDark),
                  const SizedBox(width: 12),
                  _buildNavButton(context, Icons.chevron_right, _nextMonth, isDark),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCompactHeatmap(Color habitColor, bool isDark) {
    final today = DateTime.now();
    final daysToSubtract = (today.weekday - 1);
    final currentMonday = today.subtract(Duration(days: daysToSubtract));

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 32,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   const SizedBox(height: 20), // Align with labels
                   Text("", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10)),
                   Text("", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10)),
                   Text("Wed", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10)),
                   Text("", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10)),
                   Text("Fri", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10)),
                   Text("", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10)),
                   Text("Sun", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  reverse: true, // Today on the right
                  itemCount: 52,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final weekMonday = currentMonday.subtract(Duration(days: index * 7));
                    final isFirstWeekOfMonth = weekMonday.day <= 7;
                    
                    return Container(
                      width: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 14,
                            child: isFirstWeekOfMonth 
                              ? Text(
                                  DateFormat('MMM').format(weekMonday), 
                                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 9, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.visible,
                                  softWrap: false,
                                )
                              : const SizedBox(),
                          ),
                          const SizedBox(height: 6),
                          ...List.generate(7, (dayIdx) {
                            final date = weekMonday.add(Duration(days: dayIdx));
                            final dateStr = AppDateUtils.formatDate(date);
                            final count = widget.logs[dateStr] ?? 0;
                            final isFuture = date.isAfter(today);
                            final isToday = AppDateUtils.isSameDay(date, today);
                            
                            final double intensity = widget.habit.completionsPerDay > 0 
                                ? (count / widget.habit.completionsPerDay).clamp(0.0, 1.0) 
                                : 0.0;

                            return Container(
                              width: 12,
                              height: 10,
                              margin: const EdgeInsets.symmetric(vertical: 1),
                              decoration: BoxDecoration(
                                color: count > 0 
                                    ? habitColor.withOpacity(intensity < 0.25 ? 0.25 : intensity) 
                                    : (isFuture ? Colors.transparent : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05))),
                                borderRadius: BorderRadius.circular(3),
                                border: isToday ? Border.all(color: isDark ? Colors.white : Colors.black, width: 1) : null,
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPillButton(BuildContext context, String text, bool isDark, {IconData? icon, Color? iconColor}) {
    final textColor = isDark ? Colors.white : Colors.black87;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? textColor, size: 20),
            const SizedBox(width: 8),
          ],
          Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, bool isDark, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
        ),
        child: Icon(icon, color: isDark ? Colors.white70 : Colors.black54, size: 24),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isDark ? Colors.white70 : Colors.black54, size: 24),
      ),
    );
  }

  Widget _buildWeekdayHeader(bool isDark) {
    final weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) => Expanded(
        child: Center(
          child: Text(
            day, 
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildMonthlyCalendar(Color habitColor, bool isDark) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    
    // Adjust start of grid to Monday
    int startingWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun
    final daysToSubtract = startingWeekday - 1;
    final gridStartDate = firstDayOfMonth.subtract(Duration(days: daysToSubtract));
    
    // Always show 6 weeks (42 days) for consistency
    final totalDays = 42;
    final dates = List.generate(totalDays, (index) => gridStartDate.add(Duration(days: index)));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: totalDays,
      itemBuilder: (context, index) {
        final date = dates[index];
        final isCurrentMonth = date.month == _focusedMonth.month;
        final dateStr = AppDateUtils.formatDate(date);
        final count = widget.logs[dateStr] ?? 0;
        final isCompleted = count >= widget.habit.completionsPerDay;
        final isToday = AppDateUtils.formatDate(DateTime.now()) == dateStr;

        final textColor = isCurrentMonth 
            ? (isDark ? Colors.white70 : Colors.black87)
            : (isDark ? Colors.white10 : Colors.black12);

        return Container(
          decoration: BoxDecoration(
            color: isCompleted 
                ? habitColor.withOpacity(0.2) 
                : (isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(12),
            border: isToday 
                ? Border.all(color: isDark ? Colors.white24 : Colors.black26, width: 2) 
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                "${date.day}",
                style: TextStyle(
                  color: textColor,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              if (isCompleted)
                Positioned(
                  bottom: 6,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: habitColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
