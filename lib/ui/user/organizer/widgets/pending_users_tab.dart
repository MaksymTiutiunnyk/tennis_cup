import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/pending_users_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/pending_user_card.dart';

class PendingUsersTab extends StatelessWidget {
  const PendingUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PendingUsersCubit(
        repository: ServiceLocator.adminRepository,
      ),
      child: BlocBuilder<PendingUsersCubit, PendingUsersState>(
        builder: (context, state) => switch (state) {
          PendingUsersLoading() =>
            const Center(child: CircularProgressIndicator()),
          PendingUsersError(message: final m) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(m, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.read<PendingUsersCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          PendingUsersLoaded(users: final users) => RefreshIndicator(
              onRefresh: () => context.read<PendingUsersCubit>().load(),
              child: users.isEmpty
                  ? const CustomScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          child: Center(
                              child: Text('No pending registrations')),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      itemCount: users.length,
                      itemBuilder: (_, i) => PendingUserCard(user: users[i]),
                    ),
            ),
        },
      ),
    );
  }
}
