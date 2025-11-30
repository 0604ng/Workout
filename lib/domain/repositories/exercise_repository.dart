// domain/repositories/exercise_repository.dart
import '../entities/exercise_entity.dart';

abstract class ExerciseRepository {
  Future<List<ExerciseEntity>> fetchAllExercises();
  Future<List<ExerciseEntity>> fetchExercisesByCategory(String categoryId);


  /// Cần category khi tạo mới bài tập
  Future<String> addExercise(String categoryId, ExerciseEntity exercise);
  Future<ExerciseEntity?> fetchExerciseByCategoryAndId(
      String categoryId,
      String exerciseId,
      );

  Future<void> updateExercise(
      String categoryId,
      String exerciseId,
      ExerciseEntity exercise,
      );

  Future<void> deleteExercise(String categoryId, String exerciseId);
}
