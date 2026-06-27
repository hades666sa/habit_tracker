import 'package:flutter/material.dart';

extension HabitColorParsing on String {
  Color toHabitColor([Color fallback = Colors.blue]) {
    try {
      String cleanHex = replaceAll('#', '').trim();
      if (cleanHex.startsWith('0x') || cleanHex.startsWith('0X')) {
        cleanHex = cleanHex.substring(2);
      }
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}
