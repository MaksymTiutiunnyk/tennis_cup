import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/generated/l10n.dart';
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
            final tabs = _tabsForRole(roleState.activeRole, S.of(context));
            navigationShell.goBranch(tabs.first.branchIndex,
                initialLocation: true);
          },
          builder: (context, roleState) {
            final s = S.of(context);
            final tabs = _tabsForRole(roleState.activeRole, s);
            final currentBranch = navigationShell.currentIndex;
            final visibleIdx =
                tabs.indexWhere((t) => t.branchIndex == currentBranch);
            final currentVisibleIndex = visibleIdx >= 0 ? visibleIdx : 0;

            if (visibleIdx == -1 && tabs.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                navigationShell.goBranch(tabs.first.branchIndex,
                    initialLocation: true);
              });
            }

            return Scaffold(
              appBar: AppBar(
                title: RoleTitle(roleState: roleState),
                actions: const [ModeSwitcher()],
              ),
              body: authed ? navigationShell : const AuthGate(),
              bottomNavigationBar: !authed
                  ? null
                  : BottomNavigationBar(
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

  List<_Tab> _tabsForRole(UserRole role, S s) {
    final settings = (
      branchIndex: 5,
      item: BottomNavigationBarItem(
        icon: const Icon(Icons.settings_outlined),
        label: s.tabSettings,
      ),
    );

    final tournamentsTab = (
      branchIndex: 1,
      item: BottomNavigationBarItem(
        icon: const Icon(Icons.emoji_events_outlined),
        label: s.tournaments,
      ),
    );

    return switch (role) {
      UserRole.player => [
          tournamentsTab,
          (
            branchIndex: 0,
            item: BottomNavigationBarItem(
              icon: const Icon(Icons.mail_outline),
              label: s.tabInvitations,
            ),
          ),
          settings,
        ],
      UserRole.referee => [
          tournamentsTab,
          (
            branchIndex: 7,
            item: BottomNavigationBarItem(
              icon: const Icon(Icons.mail_outline),
              label: s.tabInvitations,
            ),
          ),
          settings,
        ],
      UserRole.organizer => [
          (
            branchIndex: 2,
            item: BottomNavigationBarItem(
              icon: const Icon(Icons.emoji_events),
              label: s.tournaments,
            ),
          ),
          (
            branchIndex: 3,
            item: BottomNavigationBarItem(
              icon: const Icon(Icons.people),
              label: s.tabUsers,
            ),
          ),
          (
            branchIndex: 4,
            item: BottomNavigationBarItem(
              icon: const Icon(Icons.how_to_reg),
              label: s.tabPending,
            ),
          ),
          (
            branchIndex: 6,
            item: BottomNavigationBarItem(
              icon: const Icon(Icons.newspaper_outlined),
              label: s.newsTab,
            ),
          ),
          settings,
        ],
      UserRole.admin => [
          (
            branchIndex: 2,
            item: BottomNavigationBarItem(
              icon: const Icon(Icons.emoji_events),
              label: s.tournaments,
            ),
          ),
          (
            branchIndex: 3,
            item: BottomNavigationBarItem(
              icon: const Icon(Icons.people),
              label: s.tabUsers,
            ),
          ),
          (
            branchIndex: 4,
            item: BottomNavigationBarItem(
              icon: const Icon(Icons.how_to_reg),
              label: s.tabPending,
            ),
          ),
          (
            branchIndex: 6,
            item: BottomNavigationBarItem(
              icon: const Icon(Icons.newspaper_outlined),
              label: s.newsTab,
            ),
          ),
          settings,
        ],
    };
  }
}
