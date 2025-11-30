// FILE: lib/domain/usecases/auth_usecases.dart
import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class AuthUsecases {
  final AuthRepository repository;
  AuthUsecases(this.repository);

  Future<UserEntity?> signIn(String email, String password) => repository.signIn(email: email, password: password);
  Future<UserEntity?> register(String email, String password, String username) =>
      repository.register(email: email, password: password, username: username);
  Future<void> resetPassword(String email) => repository.resetPassword(email: email);
  Future<void> signOut() => repository.signOut();
  Stream<UserEntity?> get authStateChanges => repository.authStateChanges;
}
