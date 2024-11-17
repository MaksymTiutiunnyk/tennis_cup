import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/model/player.dart';

class PlayerSearch extends StatefulWidget {
  final void Function(BuildContext context, Player player) onSelectPlayer;

  const PlayerSearch({super.key, required this.onSelectPlayer});

  @override
  State<PlayerSearch> createState() => _PlayerSearchState();
}

class _PlayerSearchState extends State<PlayerSearch> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Player>>? searchResults;

  Future<List<Player>> searchPlayers(String value) async {
    final query = value.trim();

    if (query.isEmpty) {
      return [];
    }

    final querySnapshot = await _firestore
        .collection('players')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    final surnameQuerySnapshot = await _firestore
        .collection('players')
        .where('surname', isGreaterThanOrEqualTo: query)
        .where('surname', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    final players = <Player>{};
    players.addAll(querySnapshot.docs.map((doc) => Player.fromFirestore(doc)));
    players.addAll(
        surnameQuerySnapshot.docs.map((doc) => Player.fromFirestore(doc)));

    return players.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            textCapitalization: TextCapitalization.sentences,
            onChanged: (value) {
              setState(() {
                searchResults = searchPlayers(value);
              });
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
          child: FutureBuilder<List<Player>>(
            future: searchResults,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No players found'),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final player = snapshot.data![index];
                  return InkWell(
                    onTap: () {
                      widget.onSelectPlayer(context, player);
                    },
                    child: ListTile(
                      title: Text(player.fullName),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
