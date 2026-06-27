import 'package:flutter/material.dart';
import '../../../utils/date_utils.dart';
import '../../../providers/settings_provider.dart';

class DateScrollerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final SettingsProvider settings;

  const DateScrollerWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final today = DateTime.now();
    final startDayOffset = (today.weekday - settings.weekStartDay + 7) % 7;
    final scrollerStart = today.subtract(Duration(days: startDayOffset + 14)); 

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 35,
        itemBuilder: (context, index) {
          final date = scrollerStart.add(Duration(days: index));
          final isSelected = AppDateUtils.isSameDay(date, selectedDate);
          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppDateUtils.getShortDayName(date), 
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey, 
                      fontSize: 12,
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(), 
                    style: TextStyle(
                      color: isSelected ? Colors.white : textColor, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 18
                    )
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
