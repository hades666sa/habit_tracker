import 'package:flutter/material.dart';

class SegmentedControlWidget extends StatelessWidget {
  final String viewMode;
  final ValueChanged<String> onViewModeChanged;

  const SegmentedControlWidget({
    super.key,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildSegmentItem("Today", isDark),
          _buildSegmentItem("Weekly", isDark),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(String title, bool isDark) {
    final isSelected = viewMode == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => onViewModeChanged(title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFA191FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
