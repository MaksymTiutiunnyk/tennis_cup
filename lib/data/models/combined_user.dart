import 'package:tennis_cup/data/models/user_role.dart';

class CombinedUser {
  final int userId;
  final String firstName;
  final String lastName;
  final String avatarUrl;
  final List<UserRole> roles;

  const CombinedUser({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    required this.roles,
  });

  String get fullName => '$firstName $lastName';
  bool get isPlayer => roles.contains(UserRole.player);
  bool get isDeletable => roles.contains(UserRole.organizer);

  CombinedUser copyWith({String? avatarUrl}) => CombinedUser(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        roles: roles,
      );
}
