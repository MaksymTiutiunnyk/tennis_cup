import 'package:flutter/material.dart';
import 'package:tennis_cup/custom_icons_icons.dart';
import 'package:tennis_cup/model/player.dart';

class PlayerIntro extends StatefulWidget {
  final Player player;
  const PlayerIntro(this.player, {super.key});

  @override
  State<PlayerIntro> createState() {
    return _PlayerIntroState();
  }
}

class _PlayerIntroState extends State<PlayerIntro> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    'https://tabletennis.setkacup.com/api/Image/setka/480x480/Mi8yMy8yMzA5L2ltYWdlLmpwZw==.jpeg'),
              ),
              const SizedBox(height: 8),
              Text(
                widget.player.fullName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CustomIcons.medal,
                    size: 16,
                    color: Colors.yellow.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(30.toString()),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CustomIcons.medal,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(20.toString()),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CustomIcons.medal,
                    size: 16,
                    color: Colors.yellow.shade900,
                  ),
                  const SizedBox(width: 4),
                  Text(17.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}