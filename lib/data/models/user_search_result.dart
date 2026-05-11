import 'package:tennis_cup/data/models/user_role.dart';

class UserSearchResult {
  final int userId;
  final String firstName;
  final String lastName;
  final List<UserRole> roles;
  final String? avatarUrl;

  const UserSearchResult({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.roles = const [],
    this.avatarUrl,
  });

  String get fullName => '$firstName $lastName';
}
