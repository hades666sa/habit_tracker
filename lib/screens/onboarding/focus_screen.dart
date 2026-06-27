import 'package:flutter/material.dart';
import 'features_screen.dart';

class FocusSelectionScreen extends StatefulWidget {
  final String name;
  const FocusSelectionScreen({super.key, required this.name});

  @override
  State<FocusSelectionScreen> createState() => _FocusSelectionScreenState();
}

class _FocusSelectionScreenState extends State<FocusSelectionScreen> {
  final List<String> _selectedFocusAreas = [];

  final List<Map<String, String>> _focusAreas = [
    {'emoji': '🍎', 'label': 'Health'},
    {'emoji': '💪', 'label': 'Fitness'},
    {'emoji': '⚡', 'label': 'Productivity'},
    {'emoji': '🧠', 'label': 'Mindset'},
    {'emoji': '📚', 'label': 'Learning'},
    {'emoji': '💼', 'label': 'Career'},
    {'emoji': '🤝', 'label': 'Social'},
    {'emoji': '💰', 'label': 'Finance'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _progressSegment(true),
                  const SizedBox(width: 8),
                  _progressSegment(true),
                  const SizedBox(width: 8),
                  _progressSegment(false),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                "Identify Your Focus",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "What areas of your life would you like to improve?",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _focusAreas.length,
                  itemBuilder: (context, index) {
                    final area = _focusAreas[index];
                    final isSelected = _selectedFocusAreas.contains(area['label']);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedFocusAreas.remove(area['label']);
                          } else {
                            _selectedFocusAreas.add(area['label']!);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey[300]!,
                            width: 2,
                          ),
                          color: isSelected ? Colors.green.withOpacity(0.05) : Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(area['emoji']!, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              area['label']!,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.green : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: _selectedFocusAreas.isNotEmpty 
                      ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => FeaturesShowcaseScreen(name: widget.name, focusAreas: _selectedFocusAreas)))
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
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
