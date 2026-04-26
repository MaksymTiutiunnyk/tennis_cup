import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/features/auth/logic/auth_cubit.dart';
import 'package:tennis_cup/features/auth/presentation/auth_gate.dart';
import 'package:tennis_cup/features/player_manager/presentation/player_manager_content.dart';
import 'package:tennis_cup/logic/cubit/player_tab_index_cubit.dart';
import 'package:tennis_cup/presentation/widgets/home_widgets/mode_switcher.dart';

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
