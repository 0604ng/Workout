// data/datasources/firestore_exercise_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/exercise_entity.dart';

class FirestoreExerciseDatasource {
  final FirebaseFirestore firestore;
  final String rootCollection = 'exercise_categories';

  FirestoreExerciseDatasource({required this.firestore});

  // --------------------------------------------------------------
  // 🔹 1. Lấy tất cả bài tập từ mọi category (collectionGroup)
  // --------------------------------------------------------------
  Future<List<ExerciseEntity>> getAllExercises() async {
    try {
      final snapshot = await firestore.collectionGroup('items').get();

      final list = snapshot.docs.map(_docToEntity).toList();

      list.sort((a, b) => a.title.compareTo(b.title));
      return list;
    } catch (e) {
      print("🔥 ERROR getAllExercises: $e");
      return [];
    }
  }

  // --------------------------------------------------------------
  // 🔹 2. Lấy bài tập theo category
  // --------------------------------------------------------------
  Future<List<ExerciseEntity>> getExercisesByCategory(String categoryId) async {
    try {
      final snapshot = await firestore
          .collection(rootCollection)
          .doc(categoryId)
          .collection('items')
          .get();

      return snapshot.docs.map(_docToEntity).toList();
    } catch (e) {
      print("🔥 ERROR getExercisesByCategory: $e");
      return [];
    }
  }

  Future<ExerciseEntity?> getExerciseByCategoryAndId(
      String categoryId, String exerciseId) async {
    final doc = await firestore
        .collection(rootCollection)
        .doc(categoryId)
        .collection('items')
        .doc(exerciseId)
        .get();

    if (!doc.exists) return null;
    return _docToEntity(doc);
  }

  // --------------------------------------------------------------
  // 🔹 5. Thêm bài tập
  // --------------------------------------------------------------
  Future<String> addExercise(String categoryId, ExerciseEntity entity) async {
    try {
      final data = _entityToMap(entity, forUpdate: false);

      final docRef = await firestore
          .collection(rootCollection)
          .doc(categoryId)
          .collection('items')
          .add(data);

      return docRef.id;
    } catch (e) {
      print("🔥 ERROR addExercise: $e");
      rethrow;
    }
  }

  // --------------------------------------------------------------
  // 🔹 6. Cập nhật bài tập
  // --------------------------------------------------------------
  Future<void> updateExercise(
      String categoryId, String exerciseId, ExerciseEntity entity) async {
    try {
      final data = _entityToMap(entity, forUpdate: true);

      final ref = firestore
          .collection(rootCollection)
          .doc(categoryId)
          .collection('items')
          .doc(exerciseId);

      if (!(await ref.get()).exists) {
        print("⚠️ Cannot update, exercise not found: $exerciseId");
        return;
      }

      await ref.update(data);
    } catch (e) {
      print("🔥 ERROR updateExercise: $e");
      rethrow;
    }
  }

  // --------------------------------------------------------------
  // 🔹 7. Xóa bài tập
  // --------------------------------------------------------------
  Future<void> deleteExercise(String categoryId, String exerciseId) async {
    try {
      await firestore
          .collection(rootCollection)
          .doc(categoryId)
          .collection('items')
          .doc(exerciseId)
          .delete();
    } catch (e) {
      print("🔥 ERROR deleteExercise: $e");
    }
  }

  // --------------------------------------------------------------
  // 🔹 8. Tìm kiếm bài tập theo tên
  // --------------------------------------------------------------
  Future<List<ExerciseEntity>> searchExercisesByTitle(String query) async {
    try {
      final snapshot = await firestore.collectionGroup('items').get();

      return snapshot.docs
          .map(_docToEntity)
          .where((ex) => ex.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print("🔥 ERROR searchExercisesByTitle: $e");
      return [];
    }
  }

  // --------------------------------------------------------------
  // 🔹 9. Lọc theo độ khó
  // --------------------------------------------------------------
  Future<List<ExerciseEntity>> getExercisesByDifficulty(String difficulty) async {
    try {
      final snapshot = await firestore
          .collectionGroup('items')
          .where('difficulty', isEqualTo: difficulty)
          .get();

      return snapshot.docs.map(_docToEntity).toList();
    } catch (e) {
      print("🔥 ERROR getExercisesByDifficulty: $e");
      return [];
    }
  }

  // ==============================================================
  // 🔥 PRIVATE HELPERS
  // ==============================================================

  ExerciseEntity _docToEntity(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ExerciseEntity(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
      durationSeconds: (data['durationSeconds'] ?? 0) as int,
      imageUrl: data['imageUrl'] ?? '',
      difficulty: data['difficulty'] ?? 'medium',
      category: data['category'] ?? 'general',
      calories: (data['calories'] ?? 0) as int,
      reps: data['reps'] is num ? (data['reps'] as num).toInt() : data['reps'],
      sets: data['sets'] is num ? (data['sets'] as num).toInt() : data['sets'],
    );
  }

  /// forUpdate = true → không thêm createdAt
  Map<String, dynamic> _entityToMap(ExerciseEntity entity,
      {required bool forUpdate}) {
    final map = {
      'title': entity.title,
      'description': entity.description,
      'durationSeconds': entity.durationSeconds,
      'imageUrl': entity.imageUrl,
      'difficulty': entity.difficulty,
      'category': entity.category,
      'calories': entity.calories,
    };

    if (entity.reps != null) map['reps'] = entity.reps!;
    if (entity.sets != null) map['sets'] = entity.sets!;

    if (!forUpdate) {
      map['createdAt'] = FieldValue.serverTimestamp();
    }

    return map;
  }
}
