import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/presentation/screens/players_comparison.dart';
import 'package:tennis_cup/presentation/widgets/player_search.dart';
import 'package:tennis_cup/presentation/widgets/player_widgets/player_info.dart';
import 'package:tennis_cup/presentation/widgets/player_widgets/player_tournaments.dart';

class PlayerDetails extends StatelessWidget {
  final Player player;
  const PlayerDetails({super.key, required this.player});

  void _comparePlayers(BuildContext context, Player player) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => PlayersComparison(
        player1: this.player,
        player2: player,
      ),
    ));
  }

  void _showSearchField(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => PlayerSearch(onSelectPlayer: _comparePlayers),
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
                      _showSearchField(context);
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
