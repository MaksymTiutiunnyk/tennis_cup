part of 'active_role_cubit.dart';

class ActiveRoleState {
  final List<UserRole> availableRoles;
  final UserRole activeRole;
  final int invitationsReloadToken;

  const ActiveRoleState({
    required this.availableRoles,
    required this.activeRole,
    this.invitationsReloadToken = 0,
  });
}
