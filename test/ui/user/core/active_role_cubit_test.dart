import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/ui/user/core/view_models/active_role_cubit.dart';

import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  ActiveRoleCubit buildCubit() => ActiveRoleCubit();

  test('initial state has empty roles and default player activeRole', () {
    final cubit = buildCubit();
    expect(cubit.state.availableRoles, isEmpty);
    expect(cubit.state.activeRole, UserRole.player);
  });

  group('initRoles', () {
    blocTest<ActiveRoleCubit, ActiveRoleState>(
      'sets activeRole to first role when roles is non-empty',
      build: buildCubit,
      act: (cubit) =>
          cubit.initRoles([UserRole.player, UserRole.referee]),
      expect: () => [
        isA<ActiveRoleState>()
            .having((s) => s.activeRole, 'activeRole', UserRole.player)
            .having((s) => s.availableRoles, 'availableRoles',
                [UserRole.player, UserRole.referee]),
      ],
    );

    blocTest<ActiveRoleCubit, ActiveRoleState>(
      'sets empty roles and defaults to player when list is empty',
      build: buildCubit,
      act: (cubit) => cubit.initRoles([]),
      expect: () => [
        isA<ActiveRoleState>()
            .having((s) => s.availableRoles, 'availableRoles', isEmpty)
            .having((s) => s.activeRole, 'activeRole', UserRole.player),
      ],
    );
  });

  group('switchRole', () {
    blocTest<ActiveRoleCubit, ActiveRoleState>(
      'switches to referee when it is in availableRoles',
      build: buildCubit,
      seed: () => const ActiveRoleState(
        availableRoles: [UserRole.player, UserRole.referee],
        activeRole: UserRole.player,
      ),
      act: (cubit) => cubit.switchRole(UserRole.referee),
      expect: () => [
        isA<ActiveRoleState>()
            .having((s) => s.activeRole, 'activeRole', UserRole.referee),
      ],
    );

    blocTest<ActiveRoleCubit, ActiveRoleState>(
      'emits nothing when role is not in availableRoles',
      build: buildCubit,
      seed: () => const ActiveRoleState(
        availableRoles: [UserRole.player, UserRole.referee],
        activeRole: UserRole.player,
      ),
      act: (cubit) => cubit.switchRole(UserRole.organizer),
      expect: () => [],
    );
  });
}
