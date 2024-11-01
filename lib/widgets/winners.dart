import 'package:flutter/material.dart';
import 'package:tennis_cup/data/tournaments.dart';
import 'package:tennis_cup/main.dart';
import 'package:tennis_cup/widgets/winner.dart';

class Winners extends StatelessWidget {
  const Winners({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: kcolorScheme.onPrimaryContainer),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Tennis Cup: Winners',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
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
      ),
    );
  }
}
