import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/logic/cubit/tab_index_cubit.dart';
import 'package:tennis_cup/logic/cubit/video_player_cubit.dart';
import 'package:tennis_cup/presentation/screens/home.dart';
import 'package:tennis_cup/presentation/screens/news.dart';
import 'package:tennis_cup/presentation/screens/ranking.dart';
import 'package:tennis_cup/presentation/screens/schedule.dart';
import 'package:tennis_cup/presentation/widgets/home_widgets/mode_switcher.dart';

class ViewTabs extends StatelessWidget {
  const ViewTabs({super.key});

  static const _titles = [
    'Tennis Cup: Home page',
    'Tennis Cup: Schedule',
    'Tennis Cup: Ranking',
    'Tennis Cup: News',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
      builder: (context, videoState) {
        final isFullscreen = videoState is PlayerFullScreenRunning;
        return BlocBuilder<TabIndexCubit, int>(
          builder: (context, tabIndex) {
            return Scaffold(
              appBar: isFullscreen
                  ? null
                  : AppBar(
                      title: Text(_titles[tabIndex]),
                      actions: const [ModeSwitcher()],
                    ),
              body: switch (tabIndex) {
                1 => const Schedule(),
                2 => const Ranking(),
                3 => const News(),
                _ => const Home(),
              },
              bottomNavigationBar: isFullscreen
                  ? null
                  : BottomNavigationBar(
                      currentIndex: tabIndex,
                      onTap: context.read<TabIndexCubit>().selectTab,
                      items: const [
                        BottomNavigationBarItem(
                            icon: Icon(Icons.home), label: 'Home'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.schedule), label: 'Schedule'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.people), label: 'Ranking'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.newspaper), label: 'News'),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}
