import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/exercise_entity.dart';

class FirestorePlanDatasource {
  final FirebaseFirestore firestore;
  FirestorePlanDatasource(this.firestore);

  /// 🟢 Tạo mới một kế hoạch tập luyện (Plan)
  Future<void> createPlan(PlanEntity plan) async {
    final docRef = firestore.collection('plans').doc(plan.id);
    await docRef.set({
      'userId': plan.userId,
      'date': Timestamp.fromDate(plan.date),
      'exercises': plan.exercises.map((e) {
        // FIX: Lưu đầy đủ các trường bao gồm calories, category, reps, sets
        final exerciseMap = {
          'id': e.id,
          'title': e.title,
          'description': e.description,
          'durationSeconds': e.durationSeconds,
          'imageUrl': e.imageUrl,
          'difficulty': e.difficulty,
          'category': e.category,
          'calories': e.calories,
        };

        // Chỉ thêm reps/sets nếu có giá trị
        if (e.reps != null) exerciseMap['reps'] = e.reps!;
        if (e.sets != null) exerciseMap['sets'] = e.sets!;

        return exerciseMap;
      }).toList(),
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// 🟢 Lấy danh sách plan trong khoảng thời gian
  Future<List<PlanEntity>> getPlansInRange(
      String userId, DateTime start, DateTime end) async {
    final q = await firestore
        .collection('plans')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    return q.docs.map((doc) {
      final d = doc.data();
      final ts = d['date'] as Timestamp;

      final exercises = (d['exercises'] as List? ?? []).map((e) {
        // FIX: Thêm calories và category khi parse từ Firestore
        return ExerciseEntity(
          id: e['id'] ?? '',
          title: e['title'] ?? '',
          description: e['description'] ?? '',
          durationSeconds: (e['durationSeconds'] ?? 0) as int,
          imageUrl: e['imageUrl'] ?? '',
          difficulty: e['difficulty'] ?? 'beginner',
          category: e['category'] ?? 'general', // FIX: Thêm category
          calories: (e['calories'] ?? 0) as int, // FIX: Thêm calories
          reps: e['reps'] as int?, // Optional
          sets: e['sets'] as int?, // Optional
        );
      }).toList();

      return PlanEntity(
        id: doc.id,
        userId: d['userId'] ?? '',
        date: ts.toDate(),
        exercises: exercises,
      );
    }).toList();
  }

  /// 🟢 Cập nhật kế hoạch tập luyện
  Future<void> updatePlan(PlanEntity plan) async {
    await firestore.collection('plans').doc(plan.id).update({
      'exercises': plan.exercises.map((e) {
        // FIX: Lưu đầy đủ các trường khi update
        final exerciseMap = {
          'id': e.id,
          'title': e.title,
          'description': e.description,
          'durationSeconds': e.durationSeconds,
          'imageUrl': e.imageUrl,
          'difficulty': e.difficulty,
          'category': e.category,
          'calories': e.calories,
        };

        // Chỉ thêm reps/sets nếu có giá trị
        if (e.reps != null) exerciseMap['reps'] = e.reps!;
        if (e.sets != null) exerciseMap['sets'] = e.sets!;

        return exerciseMap;
      }).toList(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// 🟢 Xoá kế hoạch
  Future<void> deletePlan(String id) async {
    await firestore.collection('plans').doc(id).delete();
  }
}