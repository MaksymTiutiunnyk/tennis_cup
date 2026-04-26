import 'package:flutter/material.dart';
import 'package:tennis_cup/features/player_manager/presentation/settings_tab.dart';

class PlayerManagerContent extends StatelessWidget {
  final int tabIndex;

  const PlayerManagerContent({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return switch (tabIndex) {
      1 => const Center(child: Text('Notifications')),
      2 => const SettingsTab(),
      _ => const Center(child: Text('Tournaments')),
    };
  }
}
