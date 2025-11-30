import '../entities/workout_log_entity.dart';

abstract class WorkoutLogRepository {
  Future<void> createWorkoutLog(WorkoutLog log);
  Future<List<WorkoutLog>> getWorkoutLogs(String userId);
}
