import 'package:flutter/material.dart';
import '../../domain/entities/workout_log_entity.dart';
import '../../domain/usecases/create_workout_log_usecase.dart';
import '../../domain/usecases/get_user_workout_logs_usecase.dart';

class WorkoutLogProvider with ChangeNotifier {
  final CreateWorkoutLogUseCase createLogUseCase;
  final GetUserWorkoutLogsUseCase getLogsUseCase;

  List<WorkoutLog> logs = [];

  WorkoutLogProvider({
    required this.createLogUseCase,
    required this.getLogsUseCase,
  });

  Future<void> createLog(WorkoutLog log) async {
    await createLogUseCase(log);
    await loadLogs(log.userId);
  }

  Future<void> loadLogs(String userId) async {
    logs = await getLogsUseCase(userId);
    notifyListeners();
  }
}
