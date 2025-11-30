// lib/data/datasources/firestore_workout_log_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreWorkoutLogDatasource {
  final FirebaseFirestore firestore;

  FirestoreWorkoutLogDatasource(this.firestore);

  Future<void> createWorkoutLog(Map<String, dynamic> data) async {
    await firestore.collection('workout_logs').add(data);
  }

  Future<List<Map<String, dynamic>>> getWorkoutLogs(String userId) async {
    final snapshot = await firestore
        .collection('workout_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final map = Map<String, dynamic>.from(doc.data());
      map['id'] = doc.id; // add Firestore doc id
      return map;
    }).toList();
  }
}
