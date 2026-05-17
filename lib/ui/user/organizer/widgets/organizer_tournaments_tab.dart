import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/ui/core/widgets/async_state_widget.dart';
import 'package:tennis_cup/ui/core/widgets/refreshable_list.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/organizer_tournaments_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/tournament_card.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/tournament_form.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arena_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arenas_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/schedule_date_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/time_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/widgets/schedule_panel.dart';

class OrganizerTournamentsTab extends StatelessWidget {
  const OrganizerTournamentsTab({super.key});

  Future<void> _reload(BuildContext context) =>
      context.read<OrganizerTournamentsCubit>().load(
            date: context.read<ScheduleDateCubit>().state,
            arena: context.read<ArenaFilterCubit>().state,
            time: context.read<TimeFilterCubit>().state,
          );

  void _openForm(BuildContext context, Tournament? existing) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<OrganizerTournamentsCubit>(),
        child: TournamentForm(existing: existing),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ScheduleDateCubit(DateTime.now())),
        BlocProvider(
          create: (_) => ArenaFilterCubit(
            const Arena(
                id: '1',
                title: 'Kyiv Yellow Arena',
                color: ArenaColor.yellow,
                city: 'Kyiv'),
          ),
        ),
        BlocProvider(create: (_) => TimeFilterCubit(Time.Evening)),
        BlocProvider(
          create: (_) => ArenasCubit(
            arenaRepository: ServiceLocator.arenaRepository,
          ),
        ),
        BlocProvider(
          create: (context) => OrganizerTournamentsCubit(
            repository: ServiceLocator.tournamentRepository,
          )..load(
              date: context.read<ScheduleDateCubit>().state,
              arena: context.read<ArenaFilterCubit>().state,
              time: context.read<TimeFilterCubit>().state,
            ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ScheduleDateCubit, DateTime>(
            listener: (context, date) =>
                context.read<OrganizerTournamentsCubit>().load(
                      date: date,
                      arena: context.read<ArenaFilterCubit>().state,
                      time: context.read<TimeFilterCubit>().state,
                    ),
          ),
          BlocListener<ArenaFilterCubit, Arena>(
            listener: (context, arena) =>
                context.read<OrganizerTournamentsCubit>().load(
                      date: context.read<ScheduleDateCubit>().state,
                      arena: arena,
                      time: context.read<TimeFilterCubit>().state,
                    ),
          ),
          BlocListener<TimeFilterCubit, Time>(
            listener: (context, time) =>
                context.read<OrganizerTournamentsCubit>().load(
                      date: context.read<ScheduleDateCubit>().state,
                      arena: context.read<ArenaFilterCubit>().state,
                      time: time,
                    ),
          ),
        ],
        child: Scaffold(
          body: Column(
            children: [
              const SchedulePanel(),
              Expanded(
                child: BlocBuilder<OrganizerTournamentsCubit,
                    OrganizerTournamentsState>(
                  builder: (context, state) => AsyncStateWidget(
                    isLoading: state is OrgTournamentsLoading,
                    errorMessage: state is OrgTournamentsError
                        ? state.message
                        : null,
                    onRetry: () => _reload(context),
                    child: state is OrgTournamentsLoaded
                        ? RefreshableList<Tournament>(
                            items: state.tournaments,
                            onRefresh: () => _reload(context),
                            itemBuilder: (_, t) => TournamentCard(tournament: t),
                            emptyWidget: const Text('No tournaments yet'),
                            padding: const EdgeInsets.all(8),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton(
              heroTag: 'organizer_tournaments_fab',
              onPressed: () => _openForm(context, null),
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}
