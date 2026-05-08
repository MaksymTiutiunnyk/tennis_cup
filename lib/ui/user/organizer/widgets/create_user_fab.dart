import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/routing/app_router.dart';

class CreateUserFab extends StatelessWidget {
  const CreateUserFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.push(AppRoutes.createUser),
      child: const Icon(Icons.person_add),
    );
  }
}
