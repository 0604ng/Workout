import '../entities/workout_log_entity.dart';
import '../repositories/workout_log_repository.dart';

class CreateWorkoutLogUseCase {
  final WorkoutLogRepository repository;

  CreateWorkoutLogUseCase(this.repository);

  Future<void> call(WorkoutLog log) {
    return repository.createWorkoutLog(log);
  }
}
