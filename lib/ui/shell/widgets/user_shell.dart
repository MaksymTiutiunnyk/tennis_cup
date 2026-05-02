import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/auth/widgets/auth_gate.dart';
import 'package:tennis_cup/ui/settings/widgets/mode_switcher.dart';

class UserShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const UserShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final tabIndex = navigationShell.currentIndex;
        final authed = authState is AuthAuthenticated;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Account'),
            actions: const [ModeSwitcher()],
          ),
          body: authed ? navigationShell : const AuthGate(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabIndex,
            onTap: (i) => navigationShell.goBranch(
              i,
              initialLocation: i == tabIndex,
            ),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_outlined),
                  label: 'Tournaments'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_outlined),
                  label: 'Notifications'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined), label: 'Settings'),
            ],
          ),
        );
      },
    );
  }
}
