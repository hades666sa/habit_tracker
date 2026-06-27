import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../statistics/statistics_screen.dart';
import 'archive_screen.dart';
import 'widget_config_screen.dart';
import 'general_settings_screen.dart';
import '../../utils/backup_service.dart';
import 'package:flutter/services.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              icon: Icon(Icons.close, color: textColor, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text("Settings", style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            centerTitle: false,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              _buildSectionHeader("General"),
              _buildGroup(context, children: [
                _buildSettingTile(context, 
                  icon: Icons.tune,
                  color: Colors.purpleAccent,
                  label: "General Settings",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const GeneralSettingsScreen()));
                  },
                ),
              ]),
              const SizedBox(height: 32),



              _buildSectionHeader("Appearance"),
              _buildGroup(context, children: [
                _buildSettingTile(context, 
                  icon: Icons.palette,
                  color: Colors.purpleAccent,
                  label: "Theme",
                  trailing: Text(
                    settings.themeMode == ThemeMode.system ? "System" : (settings.themeMode == ThemeMode.dark ? "Dark" : "Light"),
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  onTap: () => _showThemeDialog(context, settings),
                ),
              ]),
              const SizedBox(height: 32),
              
              _buildSectionHeader("Data & Insights"),
              _buildGroup(context, children: [
                _buildSettingTile(context, 
                  icon: Icons.bar_chart,
                  color: Colors.blueAccent,
                  label: "Activity Statistics",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen()));
                  },
                ),
                _buildSettingTile(context, 
                  icon: Icons.archive_outlined,
                  color: Colors.greenAccent,
                  label: "Archived Habits",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ArchiveScreen()));
                  },
                ),
              ]),
              const SizedBox(height: 32),

              _buildSectionHeader("Data Management"),
              _buildGroup(context, children: [
                _buildSettingTile(context, 
                  icon: Icons.upload_file,
                  color: Colors.teal,
                  label: "Export Data (Backup)",
                  onTap: () async {
                    bool success = await BackupService.exportData();
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data exported successfully.')),
                      );
                    }
                  },
                ),
                _buildSettingTile(context, 
                  icon: Icons.file_download,
                  color: Colors.orange,
                  label: "Import Data (Restore)",
                  onTap: () async {
                    // Show confirmation dialog before importing
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Restore Data?'),
                        content: const Text('This will replace your current habit data with the selected backup. The app will close after successful restoration. Do you want to proceed?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Restore'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      bool success = await BackupService.importData();
                      if (success) {
                        SystemNavigator.pop(); // Close app to force reload on next open
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to import data.')),
                        );
                      }
                    }
                  },
                ),
              ]),
              const SizedBox(height: 32),



              _buildSectionHeader("Account"),
              _buildGroup(context, children: [
                _buildSettingTile(context, 
                  icon: Icons.notifications,
                  color: Colors.orangeAccent,
                  label: "Daily Check-In: ${settings.profile?.dailyReminderTime ?? 'OFF'}",
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: settings.profile?.dailyReminderTime != null
                          ? TimeOfDay(
                              hour: int.parse(settings.profile!.dailyReminderTime!.split(':')[0]),
                              minute: int.parse(settings.profile!.dailyReminderTime!.split(':')[1]),
                            )
                          : TimeOfDay.now(),
                    );
                    if (picked != null) {
                      final timeStr = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                      settings.updateProfile(settings.profile!.copyWith(dailyReminderTime: timeStr));
                    }
                  },
                ),
                _buildSettingTile(context, 
                  icon: Icons.music_note,
                  color: Colors.indigoAccent,
                  label: "Reminder Sound: ${settings.profile?.dailyReminderSound ?? 'Default'}",
                  onTap: () => _showSoundPicker(context, settings),
                ),
              ]),
              const SizedBox(height: 32),

              _buildSectionHeader("Support"),
              _buildGroup(context, children: [
                _buildSettingTile(context, 
                  icon: Icons.info_outline,
                  color: Colors.grey,
                  label: "About Loop",
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "Loop Habit Tracker",
                      applicationVersion: "1.0.0",
                      applicationIcon: const Text("♾️", style: TextStyle(fontSize: 32)),
                    );
                  },
                ),
                _buildSettingTile(context, 
                  icon: Icons.star_outline,
                  color: Colors.amberAccent,
                  label: "Rate Us",
                  onTap: () {},
                ),
              ]),
            ],
          ),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                   Text("Choose Theme", style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildThemeOption(context, settings, ThemeMode.system, "System Default", Icons.settings_brightness),
            _buildThemeOption(context, settings, ThemeMode.light, "Light Mode", Icons.light_mode),
            _buildThemeOption(context, settings, ThemeMode.dark, "Dark Mode", Icons.dark_mode),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, SettingsProvider settings, ThemeMode mode, String label, IconData icon) {
    final isSelected = settings.themeMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return InkWell(
      onTap: () {
        settings.setThemeMode(mode);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent.withOpacity(0.1) : (isDark ? Colors.white10 : Colors.black12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(label, style: TextStyle(color: textColor, fontSize: 18, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ),
            if (isSelected) 
              const Icon(Icons.check_circle, color: Colors.blueAccent, size: 24)
            else
              Icon(Icons.circle_outlined, color: isDark ? Colors.white10 : Colors.black12, size: 24),
          ],
        ),
      ),
    );
  }

  void _showSoundPicker(BuildContext context, SettingsProvider settings) {
    final sounds = ['Default', 'Elegant', 'Bright', 'Nature', 'Pulse', 'Zen'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Daily Reminder Sound", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 16),
            ...sounds.map((s) => ListTile(
              title: Text(s, style: TextStyle(color: textColor, fontWeight: settings.profile?.dailyReminderSound == s ? FontWeight.bold : FontWeight.normal)),
              trailing: settings.profile?.dailyReminderSound == s ? const Icon(Icons.check, color: Colors.blueAccent) : null,
              onTap: () {
                settings.updateProfile(settings.profile!.copyWith(dailyReminderSound: s));
                FlutterRingtonePlayer().playRingtone();
                Future.delayed(const Duration(seconds: 2), () => FlutterRingtonePlayer().stop());
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildGroup(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile(BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
