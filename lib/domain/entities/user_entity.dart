// FILE: lib/domain/entities/user_entity.dart
class UserEntity {
  final String id;
  final String email;
  final String username;
  final DateTime? dob;
  final String? location;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    this.dob,
    this.location,
  });
}
