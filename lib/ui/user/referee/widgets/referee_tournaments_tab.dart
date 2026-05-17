import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/core/widgets/async_state_widget.dart';
import 'package:tennis_cup/ui/core/widgets/refreshable_list.dart';
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
        repository: ServiceLocator.tournamentRepository,
        userId: userId,
      ),
      child: BlocBuilder<RefereeTournamentsCubit, RefereeTournamentsState>(
        builder: (context, state) => AsyncStateWidget(
          isLoading: state is RefereeTournamentsLoading,
          errorMessage: state is RefereeTournamentsError ? state.message : null,
          onRetry: context.read<RefereeTournamentsCubit>().reload,
          child: state is RefereeTournamentsLoaded
              ? RefreshableList<TournamentDto>(
                  items: state.tournaments,
                  onRefresh: () =>
                      context.read<RefereeTournamentsCubit>().reload(),
                  emptyWidget: Text(S.of(context).noActiveTournaments),
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, t) {
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
                              builder: (_) => TournamentManagementScreen(
                                tournament: t,
                              ),
                            ),
                          );
                          if (context.mounted) {
                            context.read<RefereeTournamentsCubit>().reload();
                          }
                        },
                      ),
                    );
                  },
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
