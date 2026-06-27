import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black87;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text("General", style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            centerTitle: false,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              _buildGroup(context, children: [
                _buildSettingTile(
                  context,
                  label: "Week start on ${_getDayName(settings.weekStartDay)}",
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  onTap: () => _showWeekStartPicker(context, settings),
                ),
              ]),

              _buildSectionHeader("Dashboard View Modes"),
              _buildGroup(context, children: [
                _buildSwitchTile(
                  context,
                  label: "Show View Mode Bottom Bar",
                  value: settings.showViewModeBottomBar,
                  onChanged: (v) => settings.setShowViewModeBottomBar(v),
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  context,
                  label: "Show Category Filter",
                  value: settings.showCategoryFilter,
                  onChanged: (v) => settings.setShowCategoryFilter(v),
                ),
              ]),

              _buildSectionHeaderWithPro("Customization"),
              _buildGroup(context, children: [
                _buildSwitchTile(
                  context,
                  label: "Show Streak Count",
                  value: settings.showStreakCount,
                  onChanged: (v) => settings.setShowStreakCount(v),
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  context,
                  label: "Show Streak Goal",
                  value: settings.showStreakGoal,
                  onChanged: (v) => settings.setShowStreakGoal(v),
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  context,
                  label: "Show Month Labels",
                  value: settings.showMonthLabels,
                  onChanged: (v) => settings.setShowMonthLabels(v),
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  context,
                  label: "Show Day Labels",
                  value: settings.showDayLabels,
                  onChanged: (v) => settings.setShowDayLabels(v),
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  context,
                  label: "Show Categories",
                  value: settings.showCategories,
                  onChanged: (v) => settings.setShowCategories(v),
                ),
              ]),

              _buildSectionHeader("Home Screen Widgets"),
              _buildGroup(context, children: [
                _buildSwitchTile(
                  context,
                  label: "Legacy (Performance) Mode",
                  value: settings.legacyPerformanceMode,
                  onChanged: (v) => settings.setLegacyPerformanceMode(v),
                ),
              ]),

              _buildSectionHeader("Debug"),
              _buildGroup(context, children: [
                _buildSwitchTile(
                  context,
                  label: "Allow Crashlytics",
                  value: settings.allowCrashlytics,
                  onChanged: (v) => settings.setAllowCrashlytics(v),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildSectionHeaderWithPro(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text("PRO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
        boxShadow: isDark ? [] : [
           BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05), indent: 20, endIndent: 20);
  }

  Widget _buildSettingTile(BuildContext context, {
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, {
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.purpleAccent,
          ),
        ],
      ),
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1: return "Monday";
      case 2: return "Tuesday";
      case 3: return "Wednesday";
      case 4: return "Thursday";
      case 5: return "Friday";
      case 6: return "Saturday";
      case 7: return "Sunday";
      default: return "Monday";
    }
  }

  void _showWeekStartPicker(BuildContext context, SettingsProvider settings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              const Text("Week Starts On", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Select the day of the week that starts the week", style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(7, (index) {
                    final day = index + 1;
                    final shortDay = _getDayName(day).substring(0, 3);
                    final isSelected = settings.weekStartDay == day;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          settings.setWeekStartDay(day);
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF9136E8) : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.black.withOpacity(0.1))),
                            boxShadow: isSelected ? [
                               BoxShadow(color: const Color(0xFF9136E8).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                            ] : [
                               BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))
                            ],
                          ),
                          child: Center(
                            child: Text(
                              shortDay,
                              style: TextStyle(
                                color: isSelected ? Colors.white : textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
