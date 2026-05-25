import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/tournament_invitation.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/core/widgets/async_state_widget.dart';
import 'package:tennis_cup/ui/user/core/view_models/active_role_cubit.dart';
import 'package:tennis_cup/ui/user/core/view_models/my_tournaments_cubit.dart';
import 'package:tennis_cup/ui/user/core/widgets/my_tournament_card.dart';

class MyTournamentsTab extends StatelessWidget {
  const MyTournamentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userId =
        (context.read<AuthCubit>().state as AuthAuthenticated).userId;

    return BlocBuilder<ActiveRoleCubit, ActiveRoleState>(
      buildWhen: (prev, curr) => prev.activeRole != curr.activeRole,
      builder: (context, roleState) {
        final role = roleState.activeRole == UserRole.referee
            ? InvitationRole.referee
            : InvitationRole.player;

        return BlocProvider(
          key: ValueKey(role),
          create: (_) => MyTournamentsCubit(
            repository: ServiceLocator.tournamentRepository,
            userId: userId,
            role: role,
          ),
          child: BlocListener<ActiveRoleCubit, ActiveRoleState>(
            listenWhen: (prev, curr) =>
                prev.invitationsReloadToken != curr.invitationsReloadToken,
            listener: (context, _) =>
                context.read<MyTournamentsCubit>().reload(),
            child: BlocBuilder<MyTournamentsCubit, MyTournamentsState>(
              builder: (context, state) => AsyncStateWidget(
                isLoading: state is MyTournamentsLoading,
                errorMessage:
                    state is MyTournamentsError ? state.message : null,
                onRetry: context.read<MyTournamentsCubit>().reload,
                child: state is MyTournamentsLoaded
                    ? RefreshIndicator(
                        onRefresh: () =>
                            context.read<MyTournamentsCubit>().reload(),
                        child: state.tournaments.isEmpty
                            ? CustomScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  SliverFillRemaining(
                                    child: Center(
                                      child:
                                          Text(S.of(context).noTournamentsYet),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(8),
                                itemCount: state.tournaments.length,
                                itemBuilder: (_, i) => MyTournamentCard(
                                  tournament: state.tournaments[i],
                                  role: role,
                                ),
                              ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
