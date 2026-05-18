import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/generated/l10n.dart';
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
        builder: (context, state) {
          final s = S.of(context);
          return switch (state) {
            PendingUsersLoading() =>
              const Center(child: CircularProgressIndicator()),
            PendingUsersError(message: final m) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          color: Theme.of(context).colorScheme.error, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        m,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () =>
                            context.read<PendingUsersCubit>().load(),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(s.retry),
                      ),
                    ],
                  ),
                ),
              ),
            PendingUsersLoaded(users: final users) => RefreshIndicator(
                onRefresh: () => context.read<PendingUsersCubit>().load(),
                child: users.isEmpty
                    ? CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            child: Center(
                                child: Text(s.noPendingRegistrations)),
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
          };
        },
      ),
    );
  }
}
