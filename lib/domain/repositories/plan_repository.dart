// FILE: lib/domain/repositories/plan_repository.dart
import '../entities/plan_entity.dart';

abstract class PlanRepository {
  Future<void> createPlan(PlanEntity plan);
  Future<List<PlanEntity>> getPlansByDate(String userId, DateTime date);
  Future<List<PlanEntity>> getPlansInRange(String userId, DateTime start, DateTime end);
  Future<void> updatePlan(PlanEntity plan);
  Future<void> deletePlan(String id);
}
