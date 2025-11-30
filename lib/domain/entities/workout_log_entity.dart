// lib/domain/entities/workout_log_entity.dart

class WorkoutLog {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime timestamp;
  final int totalCalories;
  final int totalDuration;
  final List<WorkoutExerciseLog> exercises;

  WorkoutLog({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.timestamp,
    required this.totalCalories,
    required this.totalDuration,
    required this.exercises,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
      'totalCalories': totalCalories,
      'totalDuration': totalDuration,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory WorkoutLog.fromMap(Map<String, dynamic> map) {
    return WorkoutLog(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      totalCalories: (map['totalCalories'] is num) ? (map['totalCalories'] as num).toInt() : 0,
      totalDuration: (map['totalDuration'] is num) ? (map['totalDuration'] as num).toInt() : 0,
      exercises: (map['exercises'] as List? ?? []).map((x) => WorkoutExerciseLog.fromMap(Map<String, dynamic>.from(x))).toList(),
    );
  }
}

class WorkoutExerciseLog {
  final String title;
  final int calories;
  final int durationSeconds;
  final DateTime timestamp;

  WorkoutExerciseLog({
    required this.title,
    required this.calories,
    required this.durationSeconds,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'calories': calories,
      'durationSeconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WorkoutExerciseLog.fromMap(Map<String, dynamic> map) {
    return WorkoutExerciseLog(
      title: map['title'] ?? '',
      calories: (map['calories'] is num) ? (map['calories'] as num).toInt() : 0,
      durationSeconds: (map['durationSeconds'] is num) ? (map['durationSeconds'] as num).toInt() : 0,
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
