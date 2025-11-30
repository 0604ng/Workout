// FILE: lib/domain/repositories/auth_repository.dart
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signIn({required String email, required String password});
  Future<UserEntity?> register({required String email, required String password, required String username});
  Future<void> resetPassword({required String email});
  Future<void> signOut();
  Stream<UserEntity?> get authStateChanges;
}
