import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_view_cubit.dart';
import 'package:tennis_cup/ui/settings/widgets/language_switcher.dart';

class LoginContent extends StatefulWidget {
  const LoginContent({super.key});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
          login: _loginController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ));
        }
      },
      builder: (context, state) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.signIn,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _loginController,
                    decoration: InputDecoration(labelText: s.loginField),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? s.required : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: s.passwordField),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? s.required : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state is AuthLoading ? null : _submit,
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(s.signIn),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: context.read<AuthViewCubit>().showRegister,
                    child: Text(s.createAccount),
                  ),
                  const SizedBox(height: 8),
                  const LanguageSwitcher(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
