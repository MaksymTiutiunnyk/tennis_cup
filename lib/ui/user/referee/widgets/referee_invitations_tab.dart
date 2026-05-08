import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/user/player/view_models/invitations_cubit.dart';
import 'package:tennis_cup/ui/user/player/widgets/tournament_invitation_card.dart';

class RefereeInvitationsTab extends StatelessWidget {
  const RefereeInvitationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userId =
        (context.read<AuthCubit>().state as AuthAuthenticated).userId;
    return BlocProvider(
      create: (_) => InvitationsCubit(
        repository: ServiceLocator.invitationsRepository,
        userId: userId,
      ),
      child: BlocBuilder<InvitationsCubit, InvitationsState>(
        builder: (context, state) => switch (state) {
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
        },
      ),
    );
  }
}
