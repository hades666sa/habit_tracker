import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime parseDate(String dateStr) {
    return DateTime.parse(dateStr);
  }

  static List<DateTime> getDaysInWeek(DateTime date) {
    int currentWeekday = date.weekday;
    DateTime monday = date.subtract(Duration(days: currentWeekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }
  
  static String getDayName(DateTime date) {
    // Return Sun, Mon, Tue, Wed, Thu, Fri, Sat (First letter capitalized)
    final name = DateFormat('E').format(date);
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }
  
  static String getDayOfMonth(DateTime date) {
    return DateFormat('d').format(date);
  }

  static String getRelativeDateName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return "Today";
    if (d == yesterday) return "Yesterday";
    return DateFormat('MMM d').format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String getShortDayName(DateTime date) {
    return DateFormat('E').format(date).toUpperCase();
  }
}
