import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/custom_exercise_entity.dart';

class FirestoreCustomExerciseDatasource {
  final FirebaseFirestore firestore;

  FirestoreCustomExerciseDatasource({required this.firestore});

  Future<void> createCustomExercise(CustomExerciseEntity entity) async {
    await firestore.collection('custom_exercises').add(entity.toMap());
  }

  Future<List<CustomExerciseEntity>> getUserCustomExercises(String userId) async {
    final snapshot = await firestore
        .collection('custom_exercises')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((e) => CustomExerciseEntity.fromMap(e.id, e.data()))
        .toList();
  }
}
