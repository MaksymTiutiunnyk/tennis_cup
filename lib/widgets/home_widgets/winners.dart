import 'package:flutter/material.dart';
import 'package:tennis_cup/data/tournaments.dart';
import 'package:tennis_cup/widgets/home_widgets/winner.dart';

class Winners extends StatelessWidget {
  const Winners({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimaryContainer),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Tennis Cup: Winners',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 195,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.90),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) => Winner(
                tournament: tournaments[0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
