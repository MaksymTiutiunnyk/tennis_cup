import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/auth/widgets/auth_gate.dart';
import 'package:tennis_cup/ui/user/player/widgets/player_manager_content.dart';
import 'package:tennis_cup/ui/view_only/player_details/view_models/player_tab_index_cubit.dart';
import 'package:tennis_cup/ui/settings/widgets/mode_switcher.dart';

class PlayerTabs extends StatelessWidget {
  const PlayerTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          return BlocBuilder<PlayerTabIndexCubit, int>(
            builder: (context, playerTab) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('My Account'),
                  actions: const [ModeSwitcher()],
                ),
                body: PlayerManagerContent(tabIndex: playerTab),
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: playerTab,
                  onTap: context.read<PlayerTabIndexCubit>().selectTab,
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.emoji_events_outlined),
                        label: 'Tournaments'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.notifications_outlined),
                        label: 'Notifications'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.settings_outlined),
                        label: 'Settings'),
                  ],
                ),
              );
            },
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Account'),
            actions: const [ModeSwitcher()],
          ),
          body: const AuthGate(),
        );
      },
    );
  }
}
