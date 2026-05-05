import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/ui/settings/widgets/mode_switcher.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/video_player_cubit.dart';

class ViewShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ViewShell({super.key, required this.navigationShell});

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
        final tabIndex = navigationShell.currentIndex;
        return Scaffold(
          appBar: isFullscreen
              ? null
              : AppBar(
                  title: Text(_titles[tabIndex]),
                  actions: const [ModeSwitcher()],
                ),
          body: navigationShell,
          bottomNavigationBar: isFullscreen
              ? null
              : BottomNavigationBar(
                  currentIndex: tabIndex,
                  onTap: (i) => navigationShell.goBranch(
                    i,
                    initialLocation: i == tabIndex,
                  ),
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
  }
}
