import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/notifications/view_models/notification_cubit.dart';
import 'package:tennis_cup/ui/settings/widgets/language_switcher.dart';
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
        SnackBar(content: Text(S.of(context).passwordUpdated)),
      );
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          s.signOutConfirmTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Text(s.signOutConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<NotificationCubit>().unregisterDevice();
      if (context.mounted) context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        SectionHeader(label: s.account),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: Text(s.changePassword),
          subtitle: Text(s.changePasswordSubtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openChangePassword(context),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(s.language),
          trailing: const LanguageSwitcher(),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.logout, color: theme.colorScheme.error),
          title: Text(
            s.signOut,
            style: TextStyle(color: theme.colorScheme.error),
          ),
          onTap: () => _confirmLogout(context),
        ),
      ],
    );
  }
}
