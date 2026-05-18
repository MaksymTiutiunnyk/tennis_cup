import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/view_only/player_search/view_models/player_search_bloc.dart';

class PlayerSearch extends StatelessWidget {
  final void Function(BuildContext context, User player) onSelectPlayer;

  const PlayerSearch({super.key, required this.onSelectPlayer});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create: (context) => PlayerSearchBloc(
        playerRepository: ServiceLocator.playerRepository,
        initialState: PlayersNotFound(),
      ),
      child: Builder(
        builder: (context) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                textCapitalization: TextCapitalization.words,
                onChanged: (value) {
                  context
                      .read<PlayerSearchBloc>()
                      .add(SearchFieldChanged(value));
                },
                decoration: InputDecoration(
                  hintText: s.enterParticipantName,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.redAccent,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<PlayerSearchBloc, PlayerSearchState>(
                builder: (context, state) {
                  if (state is PlayerSearchError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                                size: 36),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (state is PlayersNotFound) {
                    return Center(
                      child: Text(s.noPlayersFound),
                    );
                  }
                  if (state is PlayerSearchLoaded) {
                    return ListView.builder(
                      itemCount: state.players.length,
                      itemBuilder: (context, index) {
                        final player = state.players[index];
                        return InkWell(
                          onTap: () {
                            onSelectPlayer(context, player);
                          },
                          child: ListTile(
                            title: Text(player.fullName),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
