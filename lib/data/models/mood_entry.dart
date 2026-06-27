class MoodEntry {
  final int? id;
  final String date; // yyyy-MM-dd
  final String mood; // Great, Good, Okay, Not Good, Bad
  final String? feeling; // Happy, Brave, etc.
  final DateTime createdAt;

  MoodEntry({
    this.id,
    required this.date,
    required this.mood,
    this.feeling,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'mood': mood,
      'feeling': feeling,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      date: map['date'],
      mood: map['mood'],
      feeling: map['feeling'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
