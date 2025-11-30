// FILE: lib/data/repositories_impl/plan_repository_impl.dart
import '../../domain/entities/plan_entity.dart';
import '../../domain/repositories/plan_repository.dart';
import '../datasources/firestore_plan_datasource.dart';

class PlanRepositoryImpl implements PlanRepository {
  final FirestorePlanDatasource ds;
  PlanRepositoryImpl(this.ds);

  @override
  Future<void> createPlan(PlanEntity plan) => ds.createPlan(plan);

  @override
  Future<void> deletePlan(String id) => ds.deletePlan(id);

  @override
  Future<List<PlanEntity>> getPlansByDate(String userId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    return ds.getPlansInRange(userId, start, end);
  }

  @override
  Future<List<PlanEntity>> getPlansInRange(String userId, DateTime start, DateTime end) =>
      ds.getPlansInRange(userId, start, end);

  @override
  Future<void> updatePlan(PlanEntity plan) => ds.updatePlan(plan);
}
