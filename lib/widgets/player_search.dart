import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';

class PlayerSearch extends StatefulWidget {
  final void Function(BuildContext context, Player player) onSelectPlayer;
  const PlayerSearch({super.key, required this.onSelectPlayer});

  @override
  State<PlayerSearch> createState() {
    return _RankingSearch();
  }
}

class _RankingSearch extends State<PlayerSearch> {
  List<Player> searchResults = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        searchResults = players
            .where((player) => player.fullName.toLowerCase().contains(query))
            .toList();
      } else {
        searchResults = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
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
          child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  widget.onSelectPlayer(context, searchResults[index]);
                },
                child: ListTile(
                  title: Text(searchResults[index].fullName),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
