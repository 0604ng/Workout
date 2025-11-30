// FILE: lib/data/repositories_impl/auth_repository_impl.dart
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/firestore_user_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource authDatasource;
  final FirestoreUserDatasource userDatasource;

  AuthRepositoryImpl({
    required this.authDatasource,
    required this.userDatasource,
  });

  @override
  Future<UserEntity?> signIn({required String email, required String password}) async {
    try {
      final user = await authDatasource.signIn(email, password);
      if (user == null) return null;
      // Optionally ensure user doc exists
      final entity = UserEntity(id: user.uid, email: user.email ?? '', username: user.displayName ?? '');
      await userDatasource.createOrUpdateUser(entity);
      return entity;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> register({required String email, required String password, required String username}) async {
    try {
      final user = await authDatasource.register(email, password, displayName: username);
      if (user == null) return null;
      final entity = UserEntity(id: user.uid, email: user.email ?? '', username: username);
      await userDatasource.createOrUpdateUser(entity);
      return entity;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await authDatasource.resetPassword(email);
  }

  @override
  Future<void> signOut() async {
    await authDatasource.signOut();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return authDatasource.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      // Return minimal entity. More info via user datasource stream can be used.
      return UserEntity(id: user.uid, email: user.email ?? '', username: user.displayName ?? '');
    });
  }
}
