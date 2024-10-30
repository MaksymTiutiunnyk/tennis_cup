import 'package:flutter/material.dart';

import 'package:tennis_cup/widgets/live_stream_matches.dart';
import 'package:tennis_cup/widgets/upcoming_matches.dart';
import 'package:tennis_cup/widgets/winners.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  final String title = 'Tennis Cup: Home page';

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 29, 53),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: const Column(
        children: [
          LiveStreamMatches(),
          UpcomingMatches(),
          Winners(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.amber),
          BottomNavigationBarItem(
              icon: Icon(Icons.schedule), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Ranking'),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
        ],
      ),
    );
  }
}
