import 'package:flutter/material.dart';
import '../data/models/habit.dart';
import '../screens/habit_detail/habit_detail_screen.dart';
import '../utils/date_utils.dart';
import '../providers/settings_provider.dart';
import 'package:provider/provider.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final int streak;
  final DateTime selectedDate;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback? onLongPress;
  final Map<String, int> completedDates; 
  final bool isReorderMode;
  final int index;
  final String viewMode;

  const HabitCard({
    super.key,
    required this.habit,
    required this.streak,
    required this.selectedDate,
    required this.isCompleted,
    required this.onToggle,
    required this.completedDates,
    required this.index,
    required this.viewMode,
    this.isReorderMode = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsProvider, ({bool showStreakCount, bool showDayLabels, int weekStartDay})>(
      selector: (context, settings) => (
        showStreakCount: settings.showStreakCount,
        showDayLabels: settings.showDayLabels,
        weekStartDay: settings.weekStartDay,
      ),
      builder: (context, settings, _) {
        final habitColor = habit.parsedColor;

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black87;

        // Enhanced Vibrant Colors based on reference image
        final cardBgColor = habitColor.withOpacity(isDark ? 0.25 : 0.4); 
        final borderRadius = BorderRadius.circular(15); 

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)));
          },
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icon Section
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isDark ? 0.1 : 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(habit.icon, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Name Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.w800, 
                              color: textColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (settings.showStreakCount && streak > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                "🔥 $streak day streak",
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54, 
                                  fontSize: 12, 
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Right Action Section
                    if (isReorderMode)
                      ReorderableDragStartListener(
                        index: index,
                        child: Icon(Icons.drag_indicator, color: textColor.withOpacity(0.4), size: 28),
                      )
                    else
                      GestureDetector(
                        onTap: onToggle,
                        behavior: HitTestBehavior.opaque,
                        child: SegmentedProgressIcon(
                           currentCount: completedDates[AppDateUtils.formatDate(selectedDate)] ?? 0,
                           totalCount: habit.completionsPerDay,
                           color: habitColor,
                           isDark: isDark,
                        ),
                      ),
                  ],
                ),
                
                // Weekly View Strip
                if (viewMode != "Today") ...[
                  const SizedBox(height: 16),
                  _buildSimpleWeekStrip(habitColor, isDark, settings),
                ],
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildSimpleWeekStrip(Color habitColor, bool isDark, ({bool showStreakCount, bool showDayLabels, int weekStartDay}) settings) {
    final startDayOffset = (selectedDate.weekday - settings.weekStartDay + 7) % 7;
    final startDay = selectedDate.subtract(Duration(days: startDayOffset));
    final weekDates = List.generate(7, (i) => startDay.add(Duration(days: i)));
    final now = DateTime.now();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekDates.map((date) {
        final isSelectedDate = AppDateUtils.isSameDay(date, selectedDate);
        final dateStr = AppDateUtils.formatDate(date);
        final count = completedDates[dateStr] ?? 0;
        final targetCount = habit.completionsPerDay;
        final isDone = count >= targetCount;
        final isToday = AppDateUtils.isSameDay(date, now);

        return Expanded(
          child: Column(
            children: [
              if (settings.showDayLabels)
                Text(
                  AppDateUtils.getShortDayName(date)[0], 
                  style: TextStyle(
                    fontSize: 10,
                    color: isToday ? Colors.orange : (isDark ? Colors.white38 : Colors.black38),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 6),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone 
                      ? habitColor 
                      : (count > 0 ? habitColor.withOpacity(0.5) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
                  border: isSelectedDate ? Border.all(color: isDark ? Colors.white : Colors.black, width: 1.5) : null,
                ),
                child: isDone 
                  ? const Center(child: Icon(Icons.check, size: 14, color: Colors.white))
                  : (count > 0 ? Center(child: Text("$count", style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))) : null),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class SegmentedProgressIcon extends StatelessWidget {
  final int currentCount;
  final int totalCount;
  final Color color;
  final bool isDark;

  const SegmentedProgressIcon({
    super.key,
    required this.currentCount,
    required this.totalCount,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    bool isCompleted = currentCount >= totalCount;
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              size: const Size(44, 44),
              painter: SegmentedProgressPainter(
                currentCount: currentCount,
                totalCount: totalCount,
                color: color,
                isDark: isDark,
              ),
            ),
          ),
          Icon(
            isCompleted ? Icons.check : Icons.add,
            color: isCompleted ? color : (isDark ? Colors.white : Colors.black87),
            size: 22,
          ),
        ],
      ),
    );
  }
}

class SegmentedProgressPainter extends CustomPainter {
  final int currentCount;
  final int totalCount;
  final Color color;
  final bool isDark;

  SegmentedProgressPainter({
    required this.currentCount,
    required this.totalCount,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintBg = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final paintFg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    if (totalCount <= 1) {
       canvas.drawCircle(center, radius, paintBg);
       if (currentCount >= 1) {
           canvas.drawCircle(center, radius, paintFg);
       }
       return;
    }

    final double gap = 0.2;
    final double sweepAngle = (2 * 3.141592653589793 - (gap * totalCount)) / totalCount;
    
    double startAngle = -3.141592653589793 / 2; // top
    
    for (int i = 0; i < totalCount; i++) {
        bool isFilled = i < currentCount;
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            startAngle,
            sweepAngle,
            false,
            isFilled ? paintFg : paintBg,
        );
        startAngle += sweepAngle + gap;
    }
  }

  @override
  bool shouldRepaint(covariant SegmentedProgressPainter oldDelegate) {
    return oldDelegate.currentCount != currentCount ||
           oldDelegate.totalCount != totalCount ||
           oldDelegate.color != color ||
           oldDelegate.isDark != isDark;
  }
}
