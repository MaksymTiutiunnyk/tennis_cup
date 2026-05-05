import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/organizer_management_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/create_organizer_section.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/delete_organizer_section.dart';

class OrganizerManagementTab extends StatelessWidget {
  const OrganizerManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrganizerManagementCubit(
        repository: ServiceLocator.adminRepository,
      ),
      child: BlocListener<OrganizerManagementCubit, OrganizerManagementState>(
        listener: (context, state) {
          if (state is OrgManagementSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<OrganizerManagementCubit>().reset();
          } else if (state is OrgManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<OrganizerManagementCubit>().reset();
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            CreateOrganizerSection(),
            SizedBox(height: 32),
            DeleteOrganizerSection(),
          ],
        ),
      ),
    );
  }
}
