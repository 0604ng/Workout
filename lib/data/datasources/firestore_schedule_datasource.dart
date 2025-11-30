import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/schedule_entity.dart';

class FirestoreScheduleDatasource {
  final FirebaseFirestore firestore;

  FirestoreScheduleDatasource({required this.firestore});

  Future<ScheduleEntity?> getSchedule(String userId, String weekId) async {
    final ref =
    firestore.collection('schedules').doc(userId).collection('weeks').doc(weekId);

    final snapshot = await ref.get();
    if (!snapshot.exists) return null;

    return ScheduleEntity.fromMap(snapshot.id, snapshot.data()!);
  }

  Future<void> updateSchedule(String userId, ScheduleEntity schedule) async {
    final ref = firestore.collection('schedules').doc(userId).collection('weeks').doc(schedule.weekId);
    await ref.set(schedule.toMap());
  }
}
