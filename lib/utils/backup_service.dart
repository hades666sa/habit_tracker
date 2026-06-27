import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../data/database_helper.dart';

class BackupService {
  static Future<bool> exportData() async {
    try {
      final dbPath = join(await getDatabasesPath(), 'habit_tracker.db');
      final file = File(dbPath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(dbPath)],
          text: 'Habit Tracker Backup Data',
          subject: 'habit_tracker_backup.db',
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Export error: $e");
      return false;
    }
  }

  static Future<bool> importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        File selectedFile = File(result.files.single.path!);
        
        // Validate SQLite database and structure
        try {
          final testDb = await openReadOnlyDatabase(selectedFile.path);
          final tables = await testDb.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('habits', 'habit_logs', 'user_profile')"
          );
          await testDb.close();
          
          if (tables.length < 3) {
            debugPrint("Import rejected: missing required tables");
            return false;
          }
        } catch (e) {
          debugPrint("Import rejected: not a valid SQLite database: $e");
          return false;
        }

        // Close existing database safely
        await DatabaseHelper.instance.closeDatabase();
        
        final dbPath = join(await getDatabasesPath(), 'habit_tracker.db');
        
        // Overwrite existing db file
        await selectedFile.copy(dbPath);
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Import error: $e");
      return false;
    }
  }
}

