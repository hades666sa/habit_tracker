class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  final int threshold;
  final String? unlockedAt; // ISO 8601, null if locked

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.threshold,
    this.unlockedAt,
  });

  Achievement copyWith({
    Object? unlockedAt = const Object(),
  }) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      icon: icon,
      category: category,
      threshold: threshold,
      unlockedAt: unlockedAt == const Object() ? this.unlockedAt : unlockedAt as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category,
      'threshold': threshold,
      'unlocked_at': unlockedAt,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
      category: map['category'],
      threshold: map['threshold'],
      unlockedAt: map['unlocked_at'],
    );
  }

  bool get isUnlocked => unlockedAt != null;
}
