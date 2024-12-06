import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/logic/bloc/player_search_bloc.dart';

class PlayerSearch extends StatelessWidget {
  final void Function(BuildContext context, Player player) onSelectPlayer;

  const PlayerSearch({super.key, required this.onSelectPlayer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayerSearchBloc(PlayersNotFound()),
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
                  hintText: "Enter participant's last or first name",
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
                  if (state is PlayerSearchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state is PlayersNotFound) {
                    return const Center(
                      child: Text('No players found'),
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
                  return const Center(
                    child: Text('Ooops, something went wrong'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
