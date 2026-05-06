import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_tournaments_cubit.dart';
import 'package:tennis_cup/ui/user/referee/widgets/tournament_management_screen.dart';

final _dateFormat = DateFormat('dd MMM yyyy · HH:mm');

class RefereeTournamentsTab extends StatelessWidget {
  const RefereeTournamentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userId =
        (context.read<AuthCubit>().state as AuthAuthenticated).userId;
    return BlocProvider(
      create: (_) => RefereeTournamentsCubit(
        repository: ServiceLocator.refereeRepository,
        userId: userId,
      ),
      child: BlocBuilder<RefereeTournamentsCubit, RefereeTournamentsState>(
        builder: (context, state) => switch (state) {
          RefereeTournamentsLoading() =>
            const Center(child: CircularProgressIndicator()),
          RefereeTournamentsError(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: context.read<RefereeTournamentsCubit>().reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          RefereeTournamentsLoaded(:final tournaments)
              when tournaments.isEmpty =>
            const Center(child: Text('No active tournaments')),
          RefereeTournamentsLoaded(:final tournaments) => RefreshIndicator(
              onRefresh: () => context.read<RefereeTournamentsCubit>().reload(),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: tournaments.length,
                itemBuilder: (context, i) {
                  final t = tournaments[i];
                  final date = DateTime.tryParse(t.startTime);
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.emoji_events_outlined),
                      title: Text(
                        t.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: date != null
                          ? Text(
                              _dateFormat.format(date),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                TournamentManagementScreen(tournament: t),
                          ),
                        );
                        if (context.mounted) {
                          context.read<RefereeTournamentsCubit>().reload();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
        },
      ),
    );
  }
}
