import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/tournament_invitation.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/user/player/view_models/invitations_cubit.dart';
import 'package:tennis_cup/ui/user/player/widgets/tournament_invitation_card.dart';

class RefereeInvitationsTab extends StatelessWidget {
  const RefereeInvitationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InvitationsCubit(
        repository: ServiceLocator.invitationsRepository,
        status: 'PENDING',
      ),
      child: const _InvitationsListView(),
    );
  }
}

class _InvitationsListView extends StatefulWidget {
  const _InvitationsListView();

  @override
  State<_InvitationsListView> createState() => _InvitationsListViewState();
}

class _InvitationsListViewState extends State<_InvitationsListView> {
  final _listKey = GlobalKey<AnimatedListState>();
  final List<TournamentInvitation> _items = [];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocListener<InvitationsCubit, InvitationsState>(
      listener: (context, state) {
        if (state is InvitationsLoaded) {
          _syncList(state.items);
        }
      },
      child: BlocBuilder<InvitationsCubit, InvitationsState>(
        builder: (context, state) => switch (state) {
          InvitationsLoading() =>
            const Center(child: CircularProgressIndicator()),
          InvitationsError(message: final m) => Center(
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
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ),
              ),
            ),
          InvitationsLoaded() => RefreshIndicator(
              onRefresh: () => context.read<InvitationsCubit>().reload(),
              child: _items.isEmpty
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          child: Center(child: Text(s.noInvitationsYet)),
                        ),
                      ],
                    )
                  : AnimatedList(
                      key: _listKey,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      initialItemCount: _items.length,
                      itemBuilder: (_, i, animation) =>
                          _buildItem(_items[i], animation),
                    ),
            ),
        },
      ),
    );
  }

  void _syncList(List<TournamentInvitation> newItems) {
    for (var i = _items.length - 1; i >= 0; i--) {
      if (!newItems.any((n) => n.id == _items[i].id)) {
        final removed = _items[i];
        _items.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (_, animation) => _buildItem(removed, animation),
          duration: const Duration(milliseconds: 300),
        );
      }
    }
    for (final item in newItems) {
      if (!_items.any((e) => e.id == item.id)) {
        _items.add(item);
        _listKey.currentState?.insertItem(_items.length - 1);
      }
    }
  }

  Widget _buildItem(TournamentInvitation item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: TournamentInvitationCard(invitation: item),
    );
  }
}
