import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../data/models/habit.dart';
import 'date_utils.dart';

class HeatmapGenerationData {
  final Habit habit;
  final Map<String, int> logs;
  final int columns;
  final int rows;
  final String sizeKey;
  final String themeStr;
  final String tempDirPath;

  HeatmapGenerationData({
    required this.habit,
    required this.logs,
    required this.columns,
    required this.rows,
    required this.sizeKey,
    required this.themeStr,
    required this.tempDirPath,
  });
}

class MonthlyGenerationData {
  final Habit habit;
  final Map<String, int> logs;
  final String sizeKey;
  final String themeStr;
  final String tempDirPath;

  MonthlyGenerationData({
    required this.habit,
    required this.logs,
    required this.sizeKey,
    required this.themeStr,
    required this.tempDirPath,
  });
}

Future<String?> generateHeatmapImageIsolated(HeatmapGenerationData data) async {
  try {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    bool isDark = data.themeStr == 'dark';
    if (data.themeStr == 'system') isDark = true;
    
    const double boxSize = 20.0;
    const double spacing = 4.0;
    final double width = (data.columns * boxSize) + ((data.columns - 1) * spacing);
    final double height = (data.rows * boxSize) + ((data.rows - 1) * spacing);

    final rawColor = data.habit.parsedColor;
    final baseColor = Color.lerp(rawColor, Colors.white, 0.15)!;
    final emptyColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFEBEBEB);
    final today = DateTime.now();
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (int col = 0; col < data.columns; col++) {
      for (int row = 0; row < data.rows; row++) {
        final int daysAgo = ((data.columns - 1 - col) * data.rows) + (data.rows - 1 - row);
        final date = today.subtract(Duration(days: daysAgo));
        final dateStr = AppDateUtils.formatDate(date);
        final count = data.logs[dateStr] ?? 0;
        
        final double intensity = data.habit.completionsPerDay > 0 
            ? (count / data.habit.completionsPerDay).clamp(0.0, 1.0) 
            : 0.0;
            
        final bool isDone = count >= data.habit.completionsPerDay;
        
        if (isDone) {
          paint.color = baseColor;
        } else if (count > 0) {
          final double alpha = 0.4 + (intensity * 0.6);
          paint.color = Color.lerp(emptyColor, baseColor, alpha)!;
        } else {
          paint.color = emptyColor;
        }

        final rect = Rect.fromLTWH(
          col * (boxSize + spacing), 
          row * (boxSize + spacing), 
          boxSize, 
          boxSize
        );
        
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final file = File('${data.tempDirPath}/heatmap_${data.sizeKey}.png');
    await file.writeAsBytes(buffer);
    return file.path;

  } catch (e) {
    debugPrint("Error generating heatmap image: $e");
    return null;
  }
}

Future<String?> generateMonthlyCalendarImageIsolated(MonthlyGenerationData data) async {
  try {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    const columns = 6;
    const rows = 6;
    
    bool isDark = data.themeStr == 'dark';
    if (data.themeStr == 'system') isDark = true;
    
    const double boxSize = 18.0;
    const double spacing = 3.0;
    final double width = (columns * boxSize) + ((columns - 1) * spacing);
    final double height = (rows * boxSize) + ((rows - 1) * spacing);

    final rawColor = data.habit.parsedColor;
    final baseColor = Color.lerp(rawColor, Colors.white, 0.15)!;
    final emptyColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFEBEBEB);
    final paint = Paint()..style = PaintingStyle.fill;
    
    final offset = 0;
    
    for (int i = 0; i < rows * columns; i++) {
      final col = i % columns;
      final row = i ~/ columns;
      
      final rect = Rect.fromLTWH(
        col * (boxSize + spacing), 
        row * (boxSize + spacing), 
        boxSize, 
        boxSize
      );
      
      if (i >= daysInMonth) {
        paint.color = emptyColor.withOpacity(0.05);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), paint);
        continue;
      }
      
      final day = i - offset + 1;
      final date = DateTime(now.year, now.month, day);
      final dateStr = AppDateUtils.formatDate(date);
      final count = data.logs[dateStr] ?? 0;
      
      final double intensity = data.habit.completionsPerDay > 0 
          ? (count / data.habit.completionsPerDay).clamp(0.0, 1.0) 
          : 0.0;
          
      final bool isDone = count >= data.habit.completionsPerDay;
      
      if (date.isAfter(now)) {
        paint.color = emptyColor.withOpacity(0.15);
      } else if (isDone) {
        paint.color = baseColor;
      } else if (count > 0) {
        final double alpha = 0.4 + (intensity * 0.6);
        paint.color = Color.lerp(emptyColor, baseColor, alpha)!;
      } else {
        paint.color = emptyColor;
      }
      
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), paint);
      
      if (AppDateUtils.isSameDay(date, now)) {
         final strokePaint = Paint()
           ..style = PaintingStyle.stroke
           ..color = baseColor
           ..strokeWidth = 1.5;
         canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), strokePaint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final file = File('${data.tempDirPath}/heatmap_${data.sizeKey}.png');
    await file.writeAsBytes(buffer);
    return file.path;

  } catch (e) {
    debugPrint("Error generating monthly calendar image: $e");
    return null;
  }
}
