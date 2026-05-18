import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/user/core/view_models/change_password_cubit.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ChangePasswordCubit>().submit(
          currentPassword: _currentCtrl.text,
          newPassword: _newCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final submitting = state is ChangePasswordSubmitting;
        final errorMessage =
            state is ChangePasswordFailure ? state.message : null;

        return AlertDialog(
          title: Text(
            s.changePassword,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          content: SizedBox(
            width: 360,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _currentCtrl,
                    obscureText: _obscureCurrent,
                    enabled: !submitting,
                    decoration: InputDecoration(
                      labelText: s.currentPassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureCurrent
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? s.required : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newCtrl,
                    obscureText: _obscureNew,
                    enabled: !submitting,
                    decoration: InputDecoration(
                      labelText: s.newPassword,
                      helperText: s.atLeast8Chars,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 8) return s.atLeast8Chars;
                      if (v == _currentCtrl.text) return s.newPasswordMustDiffer;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    enabled: !submitting,
                    decoration: InputDecoration(
                      labelText: s.confirmNewPassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) =>
                        v != _newCtrl.text ? s.passwordsDoNotMatch : null,
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.of(context).pop(),
              child: Text(s.cancel),
            ),
            FilledButton(
              onPressed: submitting ? null : _submit,
              child: submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(s.update),
            ),
          ],
        );
      },
    );
  }
}
