import 'package:flutter/material.dart';
import 'package:tennis_cup/features/auth/presentation/login_screen.dart';
import 'package:tennis_cup/features/auth/presentation/register_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginContent(
        onSwitchToRegister: () => setState(() => _showLogin = false),
      );
    }
    return RegisterContent(
      onSwitchToLogin: () => setState(() => _showLogin = true),
    );
  }
}
