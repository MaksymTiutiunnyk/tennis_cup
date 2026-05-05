import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/user/core/view_models/change_password_cubit.dart';
import 'package:tennis_cup/ui/user/core/widgets/change_password_dialog.dart';
import 'package:tennis_cup/ui/user/player/widgets/section_header.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  Future<void> _openChangePassword(BuildContext context) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider(
        create: (_) =>
            ChangePasswordCubit(authService: ServiceLocator.authService),
        child: const ChangePasswordDialog(),
      ),
    );
    if (updated == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated.')),
      );
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Sign out?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const SectionHeader(label: 'Account'),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Change password'),
          subtitle: const Text('Update the password for your account'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openChangePassword(context),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.logout, color: theme.colorScheme.error),
          title: Text(
            'Sign out',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          onTap: () => _confirmLogout(context),
        ),
      ],
    );
  }
}
