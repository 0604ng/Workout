import '../../domain/entities/workout_log_entity.dart';
import '../../domain/repositories/workout_log_repository.dart';
import '../datasources/firestore_workout_log_datasource.dart';

class WorkoutLogRepositoryImpl implements WorkoutLogRepository {
  final FirestoreWorkoutLogDatasource datasource;

  WorkoutLogRepositoryImpl(this.datasource);

  @override
  Future<void> createWorkoutLog(WorkoutLog log) {
    return datasource.createWorkoutLog({
      'userId': log.userId,
      'createdAt': log.createdAt.toIso8601String(),
      'timestamp': log.timestamp.toIso8601String(),
      'totalCalories': log.totalCalories,
      'totalDuration': log.totalDuration,
      'exercises': log.exercises.map((e) => {
        'title': e.title,
        'calories': e.calories,
        'durationSeconds': e.durationSeconds,
        'timestamp': e.timestamp.toIso8601String(),
      }).toList(),
    });
  }

  @override
  Future<List<WorkoutLog>> getWorkoutLogs(String userId) async {
    final raw = await datasource.getWorkoutLogs(userId);

    return raw.map((e) {
      return WorkoutLog(
        id: '',
        userId: e['userId'],
        createdAt: DateTime.parse(e['createdAt']),
        timestamp: DateTime.parse(e['timestamp']),
        totalCalories: e['totalCalories'],
        totalDuration: e['totalDuration'],
        exercises: (e['exercises'] as List)
            .map((x) => WorkoutExerciseLog(
          title: x['title'],
          calories: x['calories'],
          durationSeconds: x['durationSeconds'],
          timestamp: DateTime.parse(x['timestamp']),
        ))
            .toList(),
      );
    }).toList();
  }
}
