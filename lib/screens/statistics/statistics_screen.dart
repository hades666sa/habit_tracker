import '../create_habit/create_habit_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/habit_provider.dart';
import '../../providers/habit_log_provider.dart';
import '../../data/models/habit.dart';
import '../../utils/streak_calculator.dart';
import '../../utils/date_utils.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _rateRange = "This Week";
  int _selectedHabitIndex = -1; // -1 means "Overall"

  final List<String> _ranges = [
    "This Week",
    "This Month",
    "Last Month",
    "Last 6 Months",
    "This Year",
    "Last Year",
    "All Time",
  ];

  // Statistics caching variables
  List<Habit>? _lastHabits;
  Map<int, Map<String, int>>? _lastCompletions;
  int? _lastSelectedHabitIndexCached;
  String? _lastRateRangeCached;

  int _cachedTotalCompleted = 0;
  int _cachedCurrentStreak = 0;
  int _cachedLongestStreak = 0;
  double _cachedCompletionRate = 0.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Consumer2<HabitProvider, HabitLogProvider>(
      builder: (context, habitProvider, logProvider, _) {
        final habits = habitProvider.habits
            .where((h) => h.frequency != 'ONE_TIME')
            .toList();
        final selectedHabit = _selectedHabitIndex == -1
            ? null
            : habits[_selectedHabitIndex];
        final filteredHabits = selectedHabit == null ? habits : [selectedHabit];

        Color chartColor = selectedHabit?.parsedColor ?? const Color(0xFFFF9E36);

        // Calculate Summary Stats based on selection (uses cache if data hasn't changed)
        final isCacheStale = _lastHabits == null ||
            _lastCompletions == null ||
            !identical(_lastHabits, habits) ||
            !identical(_lastCompletions, logProvider.habitCompletions) ||
            _lastSelectedHabitIndexCached != _selectedHabitIndex ||
            _lastRateRangeCached != _rateRange;

        if (isCacheStale) {
          _lastHabits = habits;
          _lastCompletions = logProvider.habitCompletions;
          _lastSelectedHabitIndexCached = _selectedHabitIndex;
          _lastRateRangeCached = _rateRange;

          int totalCompleted = 0;
          for (var h in filteredHabits) {
            totalCompleted += logProvider.getCompletionsForHabit(h.id!).length;
          }

          int currentStreak = 0;
          if (filteredHabits.isNotEmpty) {
            for (var h in filteredHabits) {
              int s = StreakCalculator.currentStreak(
                logProvider.getCompletionsForHabit(h.id!),
                h.completionsPerDay,
              );
              if (s > currentStreak) currentStreak = s;
            }
          }

          int longestStreak = 0;
          if (filteredHabits.isNotEmpty) {
            for (var h in filteredHabits) {
              int s = StreakCalculator.longestStreak(
                logProvider.getCompletionsForHabit(h.id!),
                h.completionsPerDay,
              );
              if (s > longestStreak) longestStreak = s;
            }
          }

          double completionRate = 0;
          if (filteredHabits.isNotEmpty) {
            int totalPossible = 0;
            int actualDone = 0;
            final now = DateTime.now();
            for (int i = 0; i < 30; i++) {
              final date = now.subtract(Duration(days: i));
              final dateStr = AppDateUtils.formatDate(date);
              for (var h in filteredHabits) {
                if (h.frequency == 'DAILY') {
                  totalPossible += h.completionsPerDay;
                  actualDone +=
                      (logProvider.habitCompletions[h.id!]?[dateStr] ?? 0);
                }
              }
            }
            if (totalPossible > 0) {
              completionRate = (actualDone / totalPossible) * 100;
            }
          }

          _cachedTotalCompleted = totalCompleted;
          _cachedCurrentStreak = currentStreak;
          _cachedLongestStreak = longestStreak;
          _cachedCompletionRate = completionRate;
        }

        final totalCompleted = _cachedTotalCompleted;
        final currentStreak = _cachedCurrentStreak;
        final longestStreak = _cachedLongestStreak;
        final completionRate = _cachedCompletionRate;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, shape: BoxShape.circle),
                child: Icon(Icons.menu, color: textColor, size: 20),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            centerTitle: true,
            title: Text(
              "Report",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHabitSelector(habits, isDark, textColor),
                const SizedBox(height: 24),

                // Summary Cards Layout
                Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              "🔥",
                              "$currentStreak",
                              "Current Streak",
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              "🏆",
                              "$longestStreak",
                              "Longest Streak",
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              "✅",
                              "$totalCompleted (${completionRate.toStringAsFixed(0)}%)",
                              "Period Done",
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                _buildChartSection(
                  title: "Habit Completion",
                  range: _rateRange,
                  isDark: isDark,
                  onRangeChanged: (val) => setState(() => _rateRange = val!),
                  chart: _buildLineChart(
                    isDark,
                    logProvider,
                    filteredHabits,
                    _rateRange,
                    chartColor,
                  ),
                  iconColor: chartColor,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateHabitScreen()),
            ),
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        );
      },
    );
  }

  Widget _buildHabitSelector(List<Habit> habits, bool isDark, Color textColor) {
    String title = "OVERALL";
    String subtitle = "All Categories";

    if (_selectedHabitIndex != -1 && habits.isNotEmpty) {
      final h = habits[_selectedHabitIndex];
      title = h.name.toUpperCase();
      subtitle = h.category.split(',').first;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: textColor),
            onPressed: () {
              setState(() {
                if (_selectedHabitIndex > -1) {
                  _selectedHabitIndex--;
                } else {
                  _selectedHabitIndex = habits.length - 1;
                }
              });
            },
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedHabitIndex != -1 && habits.isNotEmpty) ...[
                   Text(habits[_selectedHabitIndex].icon, style: const TextStyle(fontSize: 22)),
                   const SizedBox(width: 12),
                ],
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: textColor),
            onPressed: () {
              setState(() {
                if (_selectedHabitIndex < habits.length - 1) {
                  _selectedHabitIndex++;
                } else {
                  _selectedHabitIndex = -1;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String emoji,
    String value,
    String label,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F22) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection({
    required String title,
    required String range,
    required bool isDark,
    required ValueChanged<String?> onRangeChanged,
    required Widget chart,
    required Color iconColor,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildRangeDropdown(range, isDark, onRangeChanged),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.show_chart,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(height: 180, child: chart),
        ],
      ),
    );
  }

  Widget _buildRangeDropdown(
    String value,
    bool isDark,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          items: _ranges
              .map(
                (String r) =>
                    DropdownMenuItem<String>(value: r, child: Text(r)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBarChart(
    bool isDark,
    HabitLogProvider logProvider,
    List<Habit> habits,
    String range,
  ) {
    List<double> data = [];
    List<String> labels = [];
    final now = DateTime.now();

    if (range == "This Week") {
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        data.add(_getCompletionsForDate(logProvider, habits, date));
        labels.add(DateFormat('E').format(date));
      }
    } else if (range == "This Month" || range == "Last Month") {
      final targetMonth = range == "This Month"
          ? now
          : DateTime(now.year, now.month - 1, 1);
      final daysInMonth = DateTime(
        targetMonth.year,
        targetMonth.month + 1,
        0,
      ).day;
      int step = (daysInMonth / 4).round();
      for (int i = 0; i < 4; i++) {
        double periodTotal = 0;
        for (int j = 0; j < step; j++) {
          int dayNum = i * step + j + 1;
          if (dayNum > daysInMonth) break;
          periodTotal += _getCompletionsForDate(
            logProvider,
            habits,
            DateTime(targetMonth.year, targetMonth.month, dayNum),
          );
        }
        data.add(periodTotal);
        labels.add("W${i + 1}");
      }
    } else {
      int count = range.contains("Year") ? 12 : 6;
      for (int i = 0; i < count; i++) {
        final date = DateTime(now.year, now.month - (count - 1 - i), 1);
        data.add(_getCompletionsForMonth(logProvider, habits, date));
        labels.add(DateFormat('MMM').format(date));
      }
    }

    if (data.isEmpty) data = [0];
    double maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 5;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal + 1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          drawHorizontalLine: true,
          horizontalInterval: maxVal > 10 ? 5 : 2,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
            strokeWidth: 1.5,
            dashArray: [2, 4],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          data.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i],
                color: const Color(0xFFFF9E36),
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(
    bool isDark,
    HabitLogProvider logProvider,
    List<Habit> habits,
    String range,
    Color chartColor,
  ) {
    List<double> data = [];
    List<String> labels = [];
    final now = DateTime.now();

    if (range == "This Week") {
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        data.add(_getCompletionRateForDate(logProvider, habits, date));
        labels.add(DateFormat('E').format(date));
      }
    } else if (range == "This Month" || range == "Last Month") {
      final targetMonth = range == "This Month"
          ? now
          : DateTime(now.year, now.month - 1, 1);
      final daysInMonth = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
      
      for (int d = 1; d <= daysInMonth; d++) {
        final date = DateTime(targetMonth.year, targetMonth.month, d);
        data.add(_getCompletionRateForDate(logProvider, habits, date));
        labels.add("$d");
      }
    } else if (range == "This Year" || range == "Last Year") {
      int year = range == "This Year" ? now.year : now.year - 1;
      
      int startMonth = 1;
      DateTime? absoluteStart;
      for (var h in habits) {
         if (absoluteStart == null || h.createdAt.isBefore(absoluteStart)) {
            absoluteStart = h.createdAt;
         }
      }
      if (absoluteStart != null && absoluteStart.year == year) {
         startMonth = absoluteStart.month;
      }
      
      for (int i = startMonth; i <= 12; i++) {
        final date = DateTime(year, i, 1);
        data.add(_getCompletionRateForMonth(logProvider, habits, date));
        labels.add(DateFormat('MMM').format(date));
      }
    } else {
      int count = range == "All Time" ? 12 : 6;
      for (int i = 0; i < count; i++) {
        final date = DateTime(now.year, now.month - (count - 1 - i), 1);
        data.add(_getCompletionRateForMonth(logProvider, habits, date));
        labels.add(DateFormat('MMM').format(date));
      }
    }

    if (data.isEmpty) data = [0];
    List<FlSpot> spots = List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i]),
    );

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: 20,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
            strokeWidth: 1.5,
            dashArray: [2, 8],
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
            strokeWidth: 1.5,
            dashArray: [2, 8],
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1, // Crucial for preventing fraction indexing that leads to repeated day labels
              getTitlesWidget: (value, meta) {
                // Ensure value is treated strictly as integer index
                if (value != value.toInt().toDouble()) {
                  return const SizedBox();
                }
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  bool showLabel = true;
                  // For month ranges, show labels periodically (1st, 7th, 14th, 21st, 28th)
                  if (range == "This Month" || range == "Last Month") {
                     int day = index + 1;
                     if (day != 1 && day != 7 && day != 14 && day != 21 && day != 28) {
                        showLabel = false;
                     }
                  }
                  if (showLabel) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox();
              },
              reservedSize: 42, // Increased from 30 to prevent bottom overflow on larger font scales
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 105,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            curveSmoothness: 0.35,
            color: chartColor,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 2.5,
                color: chartColor,
                strokeWidth: 1,
                strokeColor: isDark ? const Color(0xFF1C1F22) : Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  chartColor.withOpacity(0.25),
                  chartColor.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getCompletionsForDate(
    HabitLogProvider logProvider,
    List<Habit> habits,
    DateTime date,
  ) {
    final dateStr = AppDateUtils.formatDate(date);
    double total = 0;
    for (var h in habits) {
      total += (logProvider.habitCompletions[h.id!]?[dateStr] ?? 0);
    }
    return total;
  }

  double _getCompletionsForMonth(
    HabitLogProvider logProvider,
    List<Habit> habits,
    DateTime monthDate,
  ) {
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    double monthTotal = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      monthTotal += _getCompletionsForDate(
        logProvider,
        habits,
        DateTime(monthDate.year, monthDate.month, d),
      );
    }
    return monthTotal;
  }

  double _getCompletionRateForDate(
    HabitLogProvider logProvider,
    List<Habit> habits,
    DateTime date,
  ) {
    final dateStr = AppDateUtils.formatDate(date);
    int totalP = 0, actualD = 0;
    for (var h in habits) {
      if (h.frequency == 'DAILY') {
        totalP += h.completionsPerDay;
        int comps = logProvider.habitCompletions[h.id!]?[dateStr] ?? 0;
        if (comps > h.completionsPerDay) comps = h.completionsPerDay;
        actualD += comps;
      }
    }
    return totalP > 0 ? (actualD / totalP) * 100 : 0;
  }

  double _getCompletionRateForMonth(
    HabitLogProvider logProvider,
    List<Habit> habits,
    DateTime monthDate,
  ) {
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    double totalRate = 0;
    int daysCount = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      totalRate += _getCompletionRateForDate(
        logProvider,
        habits,
        DateTime(monthDate.year, monthDate.month, d),
      );
      daysCount++;
    }
    return daysCount > 0 ? totalRate / daysCount : 0;
  }
}
