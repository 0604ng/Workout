// FILE: lib/data/datasources/firebase_auth_datasource.dart
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth auth;
  FirebaseAuthDatasource(this.auth);

  Future<User?> signIn(String email, String password) async {
    final cred = await auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  Future<User?> register(String email, String password, {String? displayName}) async {
    final cred = await auth.createUserWithEmailAndPassword(email: email, password: password);
    if (displayName != null) {
      await cred.user?.updateDisplayName(displayName);
    }
    return cred.user;
  }

  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Stream<User?> authStateChanges() => auth.authStateChanges();
}
