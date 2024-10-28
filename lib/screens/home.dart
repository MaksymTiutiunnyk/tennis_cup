import 'package:flutter/material.dart';

import 'package:tennis_cup/widgets/live_stream_match.dart';
import 'package:tennis_cup/widgets/upcoming_matches.dart';
import 'package:tennis_cup/widgets/winner.dart';

class Home extends StatefulWidget {
  const Home({super.key}) : title = 'Tennis Cup Home Page';

  final String title;

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
      body: const Center(
        child: Column(
          children: [
            Text('Tennis Cup live stream'),
            LiveStreamMatch(),
            Text('Upcoming matches'),
            UpcomingMatches(),
            Text('Winners'),
            Winner(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.schedule), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Ranking'),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
        ],
      ),
    );
  }
}
