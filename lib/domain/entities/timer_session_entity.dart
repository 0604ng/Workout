class TimerSessionEntity {
  final String id;
  final String userId;
  final String exerciseId;
  final bool isCustomExercise;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final int caloriesBurned;

  TimerSessionEntity({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.isCustomExercise,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.caloriesBurned,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'exerciseId': exerciseId,
    'isCustomExercise': isCustomExercise,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'durationSeconds': durationSeconds,
    'caloriesBurned': caloriesBurned,
  };
}
