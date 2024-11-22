import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/players_tournaments_provider.dart';
import 'package:tennis_cup/screens/players_comparison.dart';
import 'package:tennis_cup/widgets/player_search.dart';
import 'package:tennis_cup/widgets/player_widgets/player_info.dart';
import 'package:tennis_cup/widgets/player_widgets/player_tournaments.dart';

class PlayerDetails extends StatelessWidget {
  final Player player;
  const PlayerDetails({super.key, required this.player});

  Future<void> comparePlayers(
      BuildContext context, Player player, WidgetRef ref) async {
    final playersTournamentsProvider =
        StreamNotifierProvider<PlayersTournamentsNotifier, List<Tournament>>(
            () => PlayersTournamentsNotifier(
                player1Id: this.player.playerId, player2Id: player.playerId));
    ref.read(playersTournamentsProvider.notifier).reset();

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => PlayersComparison(
        player1: this.player,
        player2: player,
      ),
    ));
  }

  void showSearchField(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => PlayerSearch(onSelectPlayer: comparePlayers),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 35,
        title: const Text("Tennis Cup: Player's statistics"),
      ),
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlayerInfo(player),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showSearchField(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text('Participant to compare'),
                    ),
                  ),
                ),
                PlayerTournaments(player: player),
              ],
            ),
            Positioned(
              top: 367,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .shadow
                          .withOpacity(0.25),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  child: const Text('VS'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
