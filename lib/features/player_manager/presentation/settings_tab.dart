import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/features/auth/logic/auth_cubit.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Settings'),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () => context.read<AuthCubit>().logout(),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
