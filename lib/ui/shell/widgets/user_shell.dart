import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/auth/widgets/auth_gate.dart';
import 'package:tennis_cup/ui/settings/widgets/mode_switcher.dart';
import 'package:tennis_cup/ui/shell/widgets/role_title.dart';
import 'package:tennis_cup/ui/user/core/view_models/active_role_cubit.dart';

typedef _Tab = ({int branchIndex, BottomNavigationBarItem item});

class UserShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const UserShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final authed = authState is AuthAuthenticated;

        return BlocConsumer<ActiveRoleCubit, ActiveRoleState>(
          listenWhen: (prev, curr) =>
              prev.activeRole != curr.activeRole &&
              curr.availableRoles.isNotEmpty,
          listener: (context, roleState) {
            final tabs = _tabsForRole(roleState.activeRole);
            navigationShell.goBranch(tabs.first.branchIndex,
                initialLocation: true);
          },
          builder: (context, roleState) {
            final tabs = _tabsForRole(roleState.activeRole);
            final currentBranch = navigationShell.currentIndex;
            final visibleIdx =
                tabs.indexWhere((t) => t.branchIndex == currentBranch);
            final currentVisibleIndex = visibleIdx >= 0 ? visibleIdx : 0;

            return Scaffold(
              appBar: AppBar(
                title: RoleTitle(roleState: roleState),
                actions: const [ModeSwitcher()],
              ),
              body: authed ? navigationShell : const AuthGate(),
              bottomNavigationBar: !authed ? null : BottomNavigationBar(
                currentIndex: currentVisibleIndex,
                onTap: (i) {
                  final branchIdx = tabs[i].branchIndex;
                  navigationShell.goBranch(
                    branchIdx,
                    initialLocation: branchIdx == currentBranch,
                  );
                },
                items: tabs.map((t) => t.item).toList(),
              ),
            );
          },
        );
      },
    );
  }

  List<_Tab> _tabsForRole(UserRole role) {
    const settings = (
      branchIndex: 6,
      item: BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        label: 'Settings',
      ),
    );

    return switch (role) {
      UserRole.player => [
          (
            branchIndex: 0,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              label: 'Tournaments',
            ),
          ),
          settings,
        ],
      UserRole.referee => [
          (
            branchIndex: 1,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.sports_outlined),
              label: 'Matches',
            ),
          ),
          settings,
        ],
      UserRole.organizer => [
          (
            branchIndex: 2,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events),
              label: 'Tournaments',
            ),
          ),
          (
            branchIndex: 3,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Players',
            ),
          ),
          (
            branchIndex: 4,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.how_to_reg),
              label: 'Pending',
            ),
          ),
          (
            branchIndex: 7,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined),
              label: 'News',
            ),
          ),
          settings,
        ],
      UserRole.admin => [
          (
            branchIndex: 2,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events),
              label: 'Tournaments',
            ),
          ),
          (
            branchIndex: 3,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Players',
            ),
          ),
          (
            branchIndex: 4,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.how_to_reg),
              label: 'Pending',
            ),
          ),
          (
            branchIndex: 5,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts),
              label: 'Organizers',
            ),
          ),
          (
            branchIndex: 7,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined),
              label: 'News',
            ),
          ),
          settings,
        ],
    };
  }
}
