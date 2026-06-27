import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../data/models/user_profile.dart';
import '../main_shell.dart';

class FeaturesShowcaseScreen extends StatelessWidget {
  final String name;
  final List<String> focusAreas;

  const FeaturesShowcaseScreen({super.key, required this.name, required this.focusAreas});

  final List<Map<String, dynamic>> _features = const [
    {'icon': Icons.check_circle_outline, 'color': Colors.green, 'title': 'Shape Your Routine', 'desc': 'Create personalized habits to empower your daily life'},
    {'icon': Icons.list_alt, 'color': Colors.blue, 'title': 'Simple Check-ins', 'desc': 'One tap to mark your task complete and move on'},
    {'icon': Icons.trending_up, 'color': Colors.orange, 'title': 'Consistency Tracking', 'desc': 'Watch your streaks grow and stay motivated daily'},
    {'icon': Icons.bar_chart, 'color': Colors.purple, 'title': 'Advanced Statistics', 'desc': 'Gain deep insights through health charts and data'},
    {'icon': Icons.notifications_none, 'color': Colors.cyan, 'title': 'Custom Notifications', 'desc': 'Get reminded exactly when you need to act'},
    {'icon': Icons.palette_outlined, 'color': Colors.orangeAccent, 'title': 'Tailored Aesthetics', 'desc': 'Choose your favorite icon, color, and theme'},
    {'icon': Icons.history, 'color': Colors.deepPurple, 'title': 'Lifetime History', 'desc': 'Access your past logs and review your journey'},
    {'icon': Icons.share_outlined, 'color': Colors.pink, 'title': 'Share Achievements', 'desc': 'Export your streaks to inspire your friends'},
    {'icon': Icons.widgets_outlined, 'color': Colors.teal, 'title': 'Quick Widgets', 'desc': 'Check off habits right from your home screen'},
    {'icon': Icons.security, 'color': Colors.grey, 'title': 'Secure Privacy', 'desc': 'Your personal data is safely stored offline'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  _progressSegment(true),
                  const SizedBox(width: 8),
                  _progressSegment(true),
                  const SizedBox(width: 8),
                  _progressSegment(true),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _features.length,
                itemBuilder: (context, index) {
                  final feature = _features[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(feature['icon'], color: feature['color'], size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feature['title'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: feature['color'],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                feature['desc'],
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final settings = Provider.of<SettingsProvider>(context, listen: false);
                    await settings.updateProfile(UserProfile(
                      name: name,
                      focusAreas: focusAreas,
                      onboardingComplete: true,
                    ));
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainShell()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressSegment(bool active) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: active ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
