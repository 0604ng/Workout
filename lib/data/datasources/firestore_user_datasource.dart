// FILE: lib/data/datasources/firestore_user_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class FirestoreUserDatasource {
  final FirebaseFirestore firestore;
  FirestoreUserDatasource(this.firestore);

  Future<void> createOrUpdateUser(UserEntity user) async {
    final doc = firestore.collection('users').doc(user.id);
    await doc.set({
      'email': user.email,
      'username': user.username,
      'dob': user.dob?.toIso8601String(),
      'location': user.location ?? '',
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<UserEntity?> userStream(String uid) {
    return firestore.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data()!;
      return UserEntity(
        id: snap.id,
        email: data['email'] ?? '',
        username: data['username'] ?? '',
        dob: data['dob'] != null ? DateTime.tryParse(data['dob']) : null,
        location: data['location'],
      );
    });
  }
}
