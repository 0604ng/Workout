import 'package:flutter/material.dart';
import '../../domain/entities/workout_log_entity.dart';

class WorkoutCompletedScreen extends StatelessWidget {
  final int totalCalories;
  final int totalDuration;
  final List<WorkoutExerciseLog> exercises;

  const WorkoutCompletedScreen({
    super.key,
    required this.totalCalories,
    required this.totalDuration,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Completed')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Great job! 💪', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text('Calories burned: $totalCalories kcal'),
            Text('Duration: ${_formatDuration(totalDuration)}'),
            const SizedBox(height: 12),
            const Text('Exercises done:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: exercises.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final e = exercises[i];
                  return ListTile(
                    title: Text(e.title),
                    subtitle: Text('${e.durationSeconds}s • ${e.calories} kcal'),
                    trailing: Text('${e.timestamp.hour.toString().padLeft(2, '0')}:${e.timestamp.minute.toString().padLeft(2, '0')}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // go back to home or close workout
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Done'),
            )
          ],
        ),
      ),
    );
  }

  String _formatDuration(int s) {
    final mm = s ~/ 60;
    final ss = s % 60;
    return '${mm}m ${ss}s';
  }
}
