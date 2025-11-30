// data/repositories_impl/exercise_repository_impl.dart

import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../datasources/firestore_exercise_datasource.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final FirestoreExerciseDatasource datasource;

  ExerciseRepositoryImpl({required this.datasource});

  @override
  Future<List<ExerciseEntity>> fetchAllExercises() {
    return datasource.getAllExercises();
  }
  @override
  Future<List<ExerciseEntity>> fetchExercisesByCategory(String categoryId) {
    return datasource.getExercisesByCategory(categoryId);
  }

  @override
  Future<ExerciseEntity?> fetchExerciseByCategoryAndId(
      String categoryId,
      String exerciseId) {
    return datasource.getExerciseByCategoryAndId(categoryId, exerciseId);
  }

  @override
  Future<String> addExercise(String categoryId, ExerciseEntity exercise) {
    return datasource.addExercise(categoryId, exercise);
  }

  @override
  Future<void> updateExercise(
      String categoryId, String exerciseId, ExerciseEntity exercise) {
    return datasource.updateExercise(categoryId, exerciseId, exercise);
  }

  @override
  Future<void> deleteExercise(String categoryId, String exerciseId) {
    return datasource.deleteExercise(categoryId, exerciseId);
  }
}
