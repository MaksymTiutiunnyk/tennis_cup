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
  String pageTitle = 'Tennis Cup: Home page';

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
        pageTitle = 'Tennis Cup: Home page';
        break;
      case 1:
        activePage = const Schedule();
        pageTitle = 'Tennis Cup: Schedule';
        break;
      case 2:
        activePage = const Home();
        pageTitle = 'Tennis Cup: Ranking';
      case 3:
        activePage = const Home();
        pageTitle = 'Tennis Cup: News';
      default:
        activePage = const Home();
        pageTitle = 'Tennis Cup: Home page';
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 29, 53),
        title: Text(
          pageTitle,
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