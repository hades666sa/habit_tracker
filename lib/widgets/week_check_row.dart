import 'package:flutter/material.dart';
import '../utils/date_utils.dart';

class WeekCheckRow extends StatelessWidget {
  final Color habitColor;
  final DateTime selectedDate;

  const WeekCheckRow({
    super.key,
    required this.habitColor,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final weekDates = AppDateUtils.getDaysInWeek(selectedDate);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = weekDates[index];
        final isSelectedDate = DateUtils.isSameDay(date, selectedDate);
        
        return Expanded(
          child: Column(
            children: [
              Text(
                dayNames[index],
                style: TextStyle(
                  fontSize: 10,
                  color: isSelectedDate ? habitColor : Colors.grey,
                  fontWeight: isSelectedDate ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelectedDate ? habitColor : habitColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: isSelectedDate 
                  ? Center(child: Icon(Icons.check, size: 8, color: habitColor))
                  : null,
              ),
            ],
          ),
        );
      }),
    );
  }
}
