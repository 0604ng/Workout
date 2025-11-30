// lib/presentation/screens/start_workout_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../injection_container.dart';
import '../state/workout_session_provider.dart';
import '../../domain/entities/exercise_entity.dart';

class StartWorkoutScreen extends StatelessWidget {
  final List<ExerciseEntity> exercises;
  final int restSeconds;

  const StartWorkoutScreen({
    super.key,
    required this.exercises,
    this.restSeconds = 30,
  });

  @override
  Widget build(BuildContext context) {
    final String userId = sl<FirebaseAuth>().currentUser?.uid ?? '';

    return ChangeNotifierProvider<WorkoutSessionProvider>(
      create: (_) {
        final provider = sl<WorkoutSessionProvider>(param1: userId);
        final converted = exercises.map((e) => ExerciseItem(
          title: e.title,
          category: e.category,
          calories: e.calories,
          durationSeconds: e.durationSeconds,
          imageUrl: e.imageUrl.isNotEmpty ? e.imageUrl : null,
        )).toList();

        provider.loadExercises(converted, initialRest: restSeconds);

        return provider;
      },
      child: const _StartWorkoutBody(),
    );
  }
}

class _StartWorkoutBody extends StatelessWidget {
  const _StartWorkoutBody();

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<WorkoutSessionProvider>(context);

    if (session.exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: const Center(child: Text('No exercises')),
      );
    }

    final current = session.exercises[session.currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Exercise ${session.currentIndex + 1}/${session.exercises.length}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Column(
                children: [
                  if (current.imageUrl != null && current.imageUrl!.isNotEmpty)
                    Image.network(
                      current.imageUrl!,
                      height: 180,
                      fit: BoxFit.cover,
                    ),

                  const SizedBox(height: 12),
                  Text(
                    current.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Text(current.category),
                  const SizedBox(height: 16),

                  Text(
                    _formatTime(session.remainingSeconds),
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (session.state == SessionState.resting)
                    const Text('Rest time'),

                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _progressForCurrent(session),
                    minHeight: 8,
                  ),
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  iconSize: 36,
                  onPressed: (session.state == SessionState.running ||
                      session.state == SessionState.resting)
                      ? session.pause
                      : null,
                  icon: const Icon(Icons.pause_circle),
                ),

                ElevatedButton(
                  onPressed: () {
                    if (session.state == SessionState.paused || session.state == SessionState.idle) {
                      session.start();
                    } else {
                      session.pause();
                    }
                  },
                  child: Text(
                    session.state == SessionState.paused || session.state == SessionState.idle
                        ? 'Start'
                        : 'Pause',
                  ),
                ),

                IconButton(
                  iconSize: 36,
                  onPressed: session.skip,
                  icon: const Icon(Icons.skip_next),
                ),
              ],
            ),

            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('End workout?'),
                    content: const Text('Do you want to finish this workout now?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('No')),
                      TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Yes')),
                    ],
                  ),
                ) ??
                    false;

                if (confirm) {
                  session.forceFinish();
                }
              },
              child: const Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static double _progressForCurrent(WorkoutSessionProvider s) {
    final total = s.exercises[s.currentIndex].durationSeconds;
    final remaining = s.remainingSeconds;
    if (total == 0) return 0;
    return (total - remaining) / total;
  }
}
