import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/providers/tab_index_provider.dart';
import 'package:tennis_cup/screens/home.dart';
import 'package:tennis_cup/screens/news.dart';
import 'package:tennis_cup/screens/ranking.dart';
import 'package:tennis_cup/screens/schedule.dart';

class Tabs extends ConsumerWidget {
  const Tabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedPageIndex = ref.watch(tabIndexProvider);
    Widget activePage;
    String pageTitle;

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
        activePage = const Ranking();
        pageTitle = 'Tennis Cup: Ranking';
      case 3:
        activePage = const News();
        pageTitle = 'Tennis Cup: News';
      default:
        activePage = const Home();
        pageTitle = 'Tennis Cup: Home page';
    }
    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          ref.read(tabIndexProvider.notifier).selectTab(index);
        },
        currentIndex: selectedPageIndex,
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
