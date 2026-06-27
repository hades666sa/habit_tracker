import 'package:flutter/material.dart';
import '../utils/date_utils.dart';

class HeatmapGrid extends StatelessWidget {
  final Color habitColor;
  final Map<String, int> logs;
  final int targetCount;

  final int weeksToShow;
  final int weekStartDay;
  final DateTime? startDate;
  final DateTime? endDate;

  const HeatmapGrid({
    super.key,
    required this.habitColor,
    required this.logs,
    required this.targetCount,
    this.weeksToShow = 26,
    this.weekStartDay = 1,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final emptyColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFEBEBEB);
    final baseColor = Color.lerp(habitColor, Colors.white, 0.15)!;
    
    final targetEndDate = endDate ?? DateTime.now();
    final today = DateTime(targetEndDate.year, targetEndDate.month, targetEndDate.day);
    
    // Align grid so it ends on the last day of the current week
    final lastDayOfWeek = (weekStartDay - 1 == 0) ? 7 : (weekStartDay - 1);
    final daysUntilEnd = (lastDayOfWeek - today.weekday + 7) % 7;
    final gridEndDate = today.add(Duration(days: daysUntilEnd));

    int cols = weeksToShow;
    if (startDate != null && endDate != null) {
      final totalDays = endDate!.difference(startDate!).inDays + 1;
      cols = (totalDays / 7).ceil();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(cols, (weekIndex) {
              return Container(
                width: 10,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  children: List.generate(7, (dayIndex) {
                    DateTime date;
                    bool isOutOfRange = false;

                    if (startDate != null && endDate != null) {
                      final int dayOffset = (weekIndex * 7) + dayIndex;
                      final int totalDays = endDate!.difference(startDate!).inDays + 1;
                      
                      if (dayOffset >= totalDays) {
                        isOutOfRange = true;
                        date = endDate!; // dummy
                      } else {
                        date = startDate!.add(Duration(days: dayOffset));
                      }
                    } else {
                      final actualWeekIndex = (cols - 1) - weekIndex;
                      date = gridEndDate.subtract(Duration(days: (actualWeekIndex * 7) + (6 - dayIndex)));
                    }

                    if (isOutOfRange) {
                      return Container(width: 10, height: 10, margin: const EdgeInsets.symmetric(vertical: 1));
                    }

                    final dateStr = AppDateUtils.formatDate(date);
                    final count = logs[dateStr] ?? 0;
                    final isFuture = date.isAfter(DateTime.now());

                    double intensity = targetCount > 0 ? (count / targetCount).clamp(0.0, 1.0) : 0.0;
                    final bool isDone = count >= targetCount;

                    Color cellColor;
                    if (isFuture) {
                      cellColor = emptyColor.withOpacity(0.15);
                    } else if (isDone) {
                      cellColor = baseColor;
                    } else if (count > 0) {
                      final double alpha = 0.4 + (intensity * 0.6);
                      cellColor = Color.lerp(emptyColor, baseColor, alpha)!;
                    } else {
                      cellColor = emptyColor;
                    }

                    return Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(weeksToShow > 26 ? "1 YEAR AGO" : "6 MONTHS AGO", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Text("LESS", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10)),
                const SizedBox(width: 4),
                ...List.generate(5, (i) {
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: i == 0 
                        ? emptyColor 
                        : Color.lerp(emptyColor, baseColor, 0.4 + ((i / 4.0) * 0.6)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
                const SizedBox(width: 4),
                Text("MORE", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10)),
              ],
            ),
            Text("TODAY", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
