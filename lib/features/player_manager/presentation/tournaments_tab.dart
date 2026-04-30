import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/features/player_manager/logic/invitations_cubit.dart';
import 'package:tennis_cup/features/player_manager/presentation/tournament_invitation_card.dart';

class TournamentsTab extends StatelessWidget {
  const TournamentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvitationsCubit, InvitationsState>(
      builder: (context, state) {
        return switch (state) {
          InvitationsLoading() =>
            const Center(child: CircularProgressIndicator()),
          InvitationsError(message: final m) => Center(child: Text(m)),
          InvitationsLoaded(items: final items) when items.isEmpty =>
            const Center(child: Text('No invitations yet')),
          InvitationsLoaded(items: final items) => ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (_, i) =>
                  TournamentInvitationCard(invitation: items[i]),
            ),
        };
      },
    );
  }
}
