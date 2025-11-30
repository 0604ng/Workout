// domain/entities/exercise_entity.dart

class ExerciseEntity {
  final String id;
  final String title;
  final String description;
  final int durationSeconds;
  final String imageUrl;
  final String difficulty;
  final String category;
  final int? sets;
  final int? reps;
  final int calories;

  const ExerciseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.imageUrl,
    required this.difficulty,
    required this.category,
    this.sets,
    this.reps,
    required this.calories,
  });

  /// ==============================================================
  /// 🔥 Factory from Firestore Map
  /// ==============================================================
  factory ExerciseEntity.fromMap(String id, Map<String, dynamic> data) {
    return ExerciseEntity(
      id: id,
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
      durationSeconds:
      (data['durationSeconds'] is num) ? (data['durationSeconds'] as num).toInt() : 0,
      imageUrl: data['imageUrl'] ?? '',
      difficulty: (data['difficulty'] ?? 'medium').toString().toLowerCase(),
      category: data['category'] ?? 'general',
      sets: (data['sets'] is num) ? (data['sets'] as num).toInt() : null,
      reps: (data['reps'] is num) ? (data['reps'] as num).toInt() : null,
      calories:
      (data['calories'] is num) ? (data['calories'] as num).toInt() : 0,
    );
  }

  /// ==============================================================
  /// 🔥 Convert Entity -> Map (để lưu Firestore)
  /// ==============================================================
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'durationSeconds': durationSeconds,
      'imageUrl': imageUrl,
      'difficulty': difficulty,
      'category': category,
      'calories': calories,
    };

    // Chỉ thêm nếu có giá trị
    if (sets != null) map['sets'] = sets;
    if (reps != null) map['reps'] = reps;

    return map;
  }

  /// ==============================================================
  /// 🔥 copyWith - dùng cho update / local change
  /// ==============================================================
  ExerciseEntity copyWith({
    String? id,
    String? title,
    String? description,
    int? durationSeconds,
    String? imageUrl,
    String? difficulty,
    String? category,
    int? sets,
    int? reps,
    int? calories,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      imageUrl: imageUrl ?? this.imageUrl,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      calories: calories ?? this.calories,
    );
  }
}
