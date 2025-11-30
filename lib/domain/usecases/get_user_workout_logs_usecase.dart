import '../entities/workout_log_entity.dart';
import '../repositories/workout_log_repository.dart';

class GetUserWorkoutLogsUseCase {
  final WorkoutLogRepository repository;

  GetUserWorkoutLogsUseCase(this.repository);

  Future<List<WorkoutLog>> call(String userId) {
    return repository.getWorkoutLogs(userId);
  }
}
