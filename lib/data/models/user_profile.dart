import 'package:tennis_cup/data/models/user_role.dart';

class UserProfile {
  final int userId;
  final String firstName;
  final String lastName;
  final String? patronymicName;
  final List<UserRole> roles;
  final String? birthDate;
  final String? country;
  final String? city;
  final String? gender;
  final String? avatarUrl;

  const UserProfile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.patronymicName,
    this.roles = const [],
    this.birthDate,
    this.country,
    this.city,
    this.gender,
    this.avatarUrl,
  });

  String get fullName => '$firstName $lastName';
}
