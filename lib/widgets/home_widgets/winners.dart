import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/widgets/home_widgets/winner.dart';

class Winners extends StatelessWidget {
  const Winners({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore db = FirebaseFirestore.instance;

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
            child: FutureBuilder(
              future: db.collection('tournaments').get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return PageView.builder(
                    controller: PageController(viewportFraction: 0.90),
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.size,
                    itemBuilder: (context, index) => FutureBuilder(
                      future:
                          Tournament.fromFirestore(snapshot.data!.docs[index]),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Winner(tournament: snapshot.data!);
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
