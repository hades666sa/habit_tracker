import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  static Completer<Database>? _dbCompleter;

  // Table names
  static const String tableMoodEntries = 'mood_entries';
  static const String tableUserProfile = 'user_profile';
  static const String tableHabits = 'habits';
  static const String tableJournals = 'journals';
  static const String tableHabitLogs = 'habit_logs';
  static const String tableAchievements = 'achievements';
  
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    if (_dbCompleter == null) {
      _dbCompleter = Completer<Database>();
      try {
        final db = await _initDatabase();
        _database = db;
        _dbCompleter!.complete(db);
      } catch (e) {
        _dbCompleter!.completeError(e);
        _dbCompleter = null; 
      }
    }
    return _dbCompleter!.future;
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _dbCompleter = null;
    }
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'habit_tracker.db');
    return openDatabase(
      path, 
      version: 8, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.transaction((txn) async {
      if (oldVersion < 2) {
        await txn.execute('ALTER TABLE $tableUserProfile ADD COLUMN daily_reminder_time TEXT');
      }
      if (oldVersion < 3) {
        await txn.execute('ALTER TABLE $tableHabits ADD COLUMN frequency TEXT DEFAULT "DAILY"');
        await txn.execute('ALTER TABLE $tableHabits ADD COLUMN frequency_days TEXT');
      }
      if (oldVersion < 4) {
        try {
          await txn.execute('ALTER TABLE $tableHabits ADD COLUMN is_active INTEGER DEFAULT 1');
        } catch (_) {}
        try {
          await txn.execute('ALTER TABLE $tableHabits ADD COLUMN sort_order INTEGER DEFAULT 0');
        } catch (_) {}
      }
      if (oldVersion < 5) {
        await txn.execute('ALTER TABLE $tableHabits ADD COLUMN description TEXT DEFAULT ""');
        await txn.execute('''
          CREATE TABLE $tableJournals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      }
      if (oldVersion < 6) {
        try {
          await txn.execute('ALTER TABLE $tableUserProfile ADD COLUMN daily_reminder_sound TEXT DEFAULT "default"');
        } catch (_) {}
      }
      if (oldVersion < 7) {
        await txn.execute('''
          CREATE TABLE $tableMoodEntries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL UNIQUE,
            mood TEXT NOT NULL,
            feeling TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
      }
      if (oldVersion < 8) {
        await txn.execute('CREATE INDEX idx_habit_logs_date ON $tableHabitLogs(log_date)');
      }
    });
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE $tableMoodEntries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL UNIQUE,
          mood TEXT NOT NULL,
          feeling TEXT,
          createdAt TEXT NOT NULL
        )
      ''');

      await txn.execute('''
        CREATE TABLE $tableUserProfile (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          focus_areas TEXT NOT NULL,
          theme_mode TEXT DEFAULT 'system',
          onboarding_complete INTEGER DEFAULT 0,
          daily_reminder_time TEXT,
          daily_reminder_sound TEXT DEFAULT 'default'
        )
      ''');

      await txn.execute('''
        CREATE TABLE $tableHabits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT DEFAULT "",
          icon TEXT NOT NULL,               
          color TEXT NOT NULL,              
          category TEXT NOT NULL,           
          effort_level TEXT DEFAULT 'MEDIUM', 
          streak_goal INTEGER DEFAULT 0,    
          completions_per_day INTEGER DEFAULT 1,
          frequency TEXT DEFAULT 'DAILY',   
          frequency_days TEXT,              
          alarm_sound TEXT DEFAULT 'Default Alarm',
          reminder_time TEXT,               
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL,         
          sort_order INTEGER DEFAULT 0
        )
      ''');

      await txn.execute('''
        CREATE TABLE $tableJournals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await txn.execute('''
        CREATE TABLE $tableHabitLogs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          habit_id INTEGER NOT NULL,
          log_date TEXT NOT NULL,           
          completions_count INTEGER DEFAULT 0,
          FOREIGN KEY (habit_id) REFERENCES $tableHabits(id) ON DELETE CASCADE,
          UNIQUE(habit_id, log_date)
        )
      ''');

      await txn.execute('CREATE INDEX idx_habit_logs_date ON $tableHabitLogs(log_date)');

      await txn.execute('''
        CREATE TABLE $tableAchievements (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          icon TEXT NOT NULL,
          category TEXT NOT NULL,           
          threshold INTEGER NOT NULL,       
          unlocked_at TEXT                  
        )
      ''');
      
      await _seedDatabase(txn);
    });
  }

  Future<void> _seedDatabase(Transaction txn) async {
    final batch = txn.batch();
    
    batch.insert(tableUserProfile, {
      'id': 1,
      'name': '',
      'focus_areas': '[]',
      'theme_mode': 'system',
      'onboarding_complete': 0,
    });

    final initialAchievements = [
      {'id': 'streak_3', 'name': 'Starting Strong', 'description': 'Complete a habit for 3 days in a row', 'icon': '🔥', 'category': 'STREAK', 'threshold': 3},
      {'id': 'streak_7', 'name': 'Habit Builder', 'description': 'Complete a habit for 7 days in a row', 'icon': '🏆', 'category': 'STREAK', 'threshold': 7},
      {'id': 'streak_30', 'name': 'Unstoppable', 'description': 'Complete a habit for 30 days in a row', 'icon': '👑', 'category': 'STREAK', 'threshold': 30},
      {'id': 'total_10', 'name': 'Getting Started', 'description': 'Complete a habit 10 times in total', 'icon': '🌱', 'category': 'TOTAL_COMPLETIONS', 'threshold': 10},
      {'id': 'total_50', 'name': 'Dedicated', 'description': 'Complete a habit 50 times in total', 'icon': '⭐', 'category': 'TOTAL_COMPLETIONS', 'threshold': 50},
      {'id': 'total_100', 'name': 'Master', 'description': 'Complete a habit 100 times in total', 'icon': '💎', 'category': 'TOTAL_COMPLETIONS', 'threshold': 100},
    ];

    for (var ach in initialAchievements) {
      batch.insert(tableAchievements, ach);
    }
    
    await batch.commit(noResult: true);
  }
}
