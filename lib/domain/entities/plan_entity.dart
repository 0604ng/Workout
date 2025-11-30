// lib/domain/entities/plan_entity.dart
import 'exercise_entity.dart';

class PlanEntity {
  final String id;
  final String userId;
  final DateTime date;
  final List<ExerciseEntity> exercises;

  const PlanEntity({
    required this.id,
    required this.userId,
    required this.date,
    required this.exercises,
  });
}
