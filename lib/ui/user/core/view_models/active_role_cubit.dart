import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/user_role.dart';

part 'active_role_state.dart';

class ActiveRoleCubit extends Cubit<ActiveRoleState> {
  ActiveRoleCubit() : super(const ActiveRoleState(availableRoles: [], activeRole: UserRole.player));

  void initRoles(List<UserRole> roles) {
    if (roles.isEmpty) {
      emit(const ActiveRoleState(availableRoles: [], activeRole: UserRole.player));
      return;
    }
    emit(ActiveRoleState(availableRoles: roles, activeRole: roles.first));
  }

  void switchRole(UserRole role) {
    if (!state.availableRoles.contains(role)) return;
    emit(ActiveRoleState(
      availableRoles: state.availableRoles,
      activeRole: role,
      invitationsReloadToken: state.invitationsReloadToken,
    ));
  }

  void requestInvitationsReload() {
    emit(ActiveRoleState(
      availableRoles: state.availableRoles,
      activeRole: state.activeRole,
      invitationsReloadToken: state.invitationsReloadToken + 1,
    ));
  }
}
