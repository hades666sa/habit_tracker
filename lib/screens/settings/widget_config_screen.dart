import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:home_widget/home_widget.dart';
import '../../providers/habit_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/habit_log_provider.dart';

class WidgetConfigScreen extends StatefulWidget {
  final int? appWidgetId;
  final bool isStandalone;
  const WidgetConfigScreen({super.key, this.appWidgetId, this.isStandalone = false});

  @override
  State<WidgetConfigScreen> createState() => _WidgetConfigScreenState();
}

class _WidgetConfigScreenState extends State<WidgetConfigScreen> {
  static const _channel = MethodChannel('com.loop.habit_tracker/widget_config');

  @override
  Widget build(BuildContext context) {
    Widget content = Consumer3<HabitProvider, SettingsProvider, HabitLogProvider>(
      builder: (context, habitProvider, settingsProvider, logProvider, _) {
        if (habitProvider.habits.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Create a habit first to use widgets."),
          ));
        }

        return ListView.builder(
          shrinkWrap: widget.isStandalone,
          itemCount: habitProvider.habits.length,
          itemBuilder: (context, index) {
            final habit = habitProvider.habits[index];

            return ListTile(
              leading: Text(habit.icon, style: const TextStyle(fontSize: 24)),
              title: Text(habit.name),
              onTap: () async {
                if (widget.appWidgetId != null) {
                  await HomeWidget.saveWidgetData<String>('widget_habit_${widget.appWidgetId}', habit.id.toString());
                }
                
                final allLogs = logProvider.getCompletionsForHabit(habit.id!);
                await settingsProvider.updateWidgetForHabit(habit, allLogs);
                _finishConfig();
              },
            );
          },
        );
      },
    );

    if (widget.isStandalone) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    title: const Text('Widget Config', style: TextStyle(fontSize: 18)),
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _finishConfig,
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  Flexible(child: content),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Configuration'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _finishConfig,
        ),
      ),
      body: content,
    );
  }

  void _finishConfig() {
    try {
      if (widget.appWidgetId != null) {
        _channel.invokeMethod('finishConfig', {'appWidgetId': widget.appWidgetId});
      } else {
        _channel.invokeMethod('finishConfig');
      }
    } catch (e) {
      debugPrint("Error finishing config: $e");
    } finally {
      if (mounted) {
        if (widget.isStandalone) {
          SystemNavigator.pop();
        } else {
          Navigator.pop(context);
        }
      }
    }
  }
}
