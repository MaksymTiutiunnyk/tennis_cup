import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/core/widgets/async_state_widget.dart';
import 'package:tennis_cup/ui/user/player/view_models/tournament_schedule_preview_cubit.dart';
import 'package:tennis_cup/ui/user/player/widgets/scheduled_match_preview_row.dart';

class TournamentSchedulePreviewScreen extends StatelessWidget {
  final int tournamentId;
  final String tournamentName;

  const TournamentSchedulePreviewScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TournamentSchedulePreviewCubit(
        repository: ServiceLocator.matchRepository,
        tournamentId: tournamentId,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            tournamentName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: BlocBuilder<TournamentSchedulePreviewCubit,
            TournamentSchedulePreviewState>(
          builder: (context, state) => AsyncStateWidget(
            isLoading: state is TournamentSchedulePreviewLoading,
            errorMessage:
                state is TournamentSchedulePreviewError ? state.message : null,
            onRetry: context.read<TournamentSchedulePreviewCubit>().reload,
            child: state is TournamentSchedulePreviewLoaded
                ? RefreshIndicator(
                    onRefresh: () =>
                        context.read<TournamentSchedulePreviewCubit>().reload(),
                    child: state.matches.isEmpty
                        ? CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverFillRemaining(
                                child: Center(
                                  child: Text(
                                      S.of(context).noMatchesScheduledYet),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: state.matches.length,
                            itemBuilder: (_, i) => ScheduledMatchPreviewRow(
                              match: state.matches[i],
                            ),
                          ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
