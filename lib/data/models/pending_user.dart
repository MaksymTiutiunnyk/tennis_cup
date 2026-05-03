import 'package:equatable/equatable.dart';
import 'package:tennis_cup/data/models/user_role.dart';

class PendingUser extends Equatable {
  final int id;
  final String login;
  final List<UserRole> roles;
  final DateTime createdAt;

  const PendingUser({
    required this.id,
    required this.login,
    required this.roles,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, login, roles, createdAt];
}
