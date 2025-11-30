import 'dart:async';
import 'package:flutter/material.dart';
import 'package:workout_tracker/presentation/state/auth_provider.dart';
import '../../domain/entities/workout_log_entity.dart';
import '../../domain/usecases/create_workout_log_usecase.dart';

class ExerciseItem {
  final String title;
  final String category;
  final int calories;
  final int durationSeconds;
  final String? imageUrl;
  final int? reps;
  final int? sets;

  ExerciseItem({
    required this.title,
    required this.category,
    required this.calories,
    required this.durationSeconds,
    this.imageUrl,
    this.reps,
    this.sets,
  });
}

enum SessionState { idle, running, resting, paused, completed }

class WorkoutSessionProvider with ChangeNotifier {
  final CreateWorkoutLogUseCase createWorkoutLogUseCase;
  final AuthProvider authProvider;

  WorkoutSessionProvider({
    required this.createWorkoutLogUseCase,
    required this.authProvider, required String userId,
  });

  List<ExerciseItem> exercises = [];
  int currentIndex = 0;
  SessionState state = SessionState.idle;

  // timers
  Timer? _countdownTimer;
  int remainingSeconds = 0;
  int restSeconds = 30;

  // metrics
  int totalCalories = 0;
  int totalDuration = 0;
  List<WorkoutExerciseLog> completedExercises = [];

  String get userId => authProvider.currentUser?.uid ?? '';

  // --------------------------------------------------------
  // LOAD EXERCISES
  // --------------------------------------------------------
  void loadExercises(List<ExerciseItem> list, {int initialRest = 30}) {
    exercises = List.from(list);
    currentIndex = 0;
    state = exercises.isEmpty ? SessionState.idle : SessionState.paused;
    restSeconds = initialRest;
    remainingSeconds = exercises.isNotEmpty ? exercises[0].durationSeconds : 0;
    totalCalories = 0;
    totalDuration = 0;
    completedExercises = [];
    notifyListeners();
  }

  // --------------------------------------------------------
  // START WORKOUT
  // --------------------------------------------------------
  void start() {
    if (exercises.isEmpty) return;
    state = SessionState.running;
    remainingSeconds = exercises[currentIndex].durationSeconds;
    _startCountdown();
    notifyListeners();
  }

  // --------------------------------------------------------
  // COUNTDOWN TIMER
  // --------------------------------------------------------
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state != SessionState.running && state != SessionState.resting) {
        timer.cancel();
        return;
      }

      if (remainingSeconds > 0) {
        remainingSeconds--;
        notifyListeners();
      } else {
        if (state == SessionState.running) {
          _onExerciseFinished();
        } else if (state == SessionState.resting) {
          _onRestFinished();
        }
      }
    });
  }

  // --------------------------------------------------------
  // FINISHED EXERCISE
  // --------------------------------------------------------
  void _onExerciseFinished() {
    final ex = exercises[currentIndex];

    totalCalories += ex.calories;
    totalDuration += ex.durationSeconds;

    completedExercises.add(
      WorkoutExerciseLog(
        title: ex.title,
        calories: ex.calories,
        durationSeconds: ex.durationSeconds,
        timestamp: DateTime.now(),
      ),
    );

    if (currentIndex >= exercises.length - 1) {
      _completeWorkout();
    } else {
      state = SessionState.resting;
      remainingSeconds = restSeconds;
      _startCountdown();
      notifyListeners();
    }
  }

  // --------------------------------------------------------
  // REST FINISHED → NEXT EXERCISE
  // --------------------------------------------------------
  void _onRestFinished() {
    currentIndex++;
    state = SessionState.running;
    remainingSeconds = exercises[currentIndex].durationSeconds;
    _startCountdown();
    notifyListeners();
  }

  // --------------------------------------------------------
  // PAUSE
  // --------------------------------------------------------
  void pause() {
    if (state == SessionState.running || state == SessionState.resting) {
      state = SessionState.paused;
      _countdownTimer?.cancel();
      notifyListeners();
    }
  }

  void resume() {
    if (state == SessionState.paused) {
      state = SessionState.running;
      _startCountdown();
      notifyListeners();
    }
  }

  // --------------------------------------------------------
  // SKIP
  // --------------------------------------------------------
  void skip() {
    _countdownTimer?.cancel();

    if (state == SessionState.running) {
      final ex = exercises[currentIndex];
      final doneSeconds = ex.durationSeconds - remainingSeconds;
      final caloriesBurned =
      ((ex.calories / ex.durationSeconds) * doneSeconds).round();

      totalCalories += caloriesBurned;
      totalDuration += doneSeconds;

      completedExercises.add(
        WorkoutExerciseLog(
          title: ex.title,
          calories: caloriesBurned,
          durationSeconds: doneSeconds,
          timestamp: DateTime.now(),
        ),
      );
    }

    if (currentIndex >= exercises.length - 1) {
      _completeWorkout();
    } else {
      currentIndex++;
      state = SessionState.running;
      remainingSeconds = exercises[currentIndex].durationSeconds;
      _startCountdown();
      notifyListeners();
    }
  }

  // --------------------------------------------------------
  // FORCE FINISH (for Finish button)
  // --------------------------------------------------------
  void forceFinish() {
    _countdownTimer?.cancel();
    _completeWorkout();
  }

  // --------------------------------------------------------
  // FINAL COMPLETE
  // --------------------------------------------------------
  Future<void> _completeWorkout() async {
    _countdownTimer?.cancel();
    state = SessionState.completed;
    remainingSeconds = 0;
    notifyListeners();

    if (userId.isEmpty) return;

    final log = WorkoutLog(
      id: '',
      userId: userId,
      createdAt: DateTime.now(),
      timestamp: DateTime.now(),
      totalCalories: totalCalories,
      totalDuration: totalDuration,
      exercises: completedExercises,
    );

    try {
      await createWorkoutLogUseCase(log);
    } catch (_) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
