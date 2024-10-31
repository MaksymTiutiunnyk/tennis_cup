import 'package:flutter/material.dart';
import 'package:tennis_cup/screens/home.dart';
import 'package:tennis_cup/screens/schedule.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() {
    return _Tabs();
  }
}

class _Tabs extends State<Tabs> {
  int selectedPageIndex = 0;
  Widget activePage = const Home();

  void onSelectPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (selectedPageIndex) {
      case 0:
        activePage = const Home();
        break;
      case 1:
        activePage = const Schedule();
        break;
      default:
        activePage = const Home();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 29, 53),
        title: Text(
          'Tennis Cup: Home page',
          // activePage.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: onSelectPage,
        currentIndex: selectedPageIndex,
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
