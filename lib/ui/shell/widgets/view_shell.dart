import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/settings/widgets/mode_switcher.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/video_player_cubit.dart';

class ViewShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ViewShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final titles = [
      s.appBarTitleHome,
      s.appBarTitleSchedule,
      s.appBarTitleRanking,
      s.appBarTitleNews,
    ];

    return BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
      builder: (context, videoState) {
        final isFullscreen = videoState is PlayerFullScreenRunning;
        final tabIndex = navigationShell.currentIndex;
        return Scaffold(
          appBar: isFullscreen
              ? null
              : AppBar(
                  title: Text(titles[tabIndex]),
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
                  items: [
                    BottomNavigationBarItem(
                        icon: const Icon(Icons.home), label: s.homeTab),
                    BottomNavigationBarItem(
                        icon: const Icon(Icons.schedule), label: s.scheduleTab),
                    BottomNavigationBarItem(
                        icon: const Icon(Icons.people), label: s.rankingTab),
                    BottomNavigationBarItem(
                        icon: const Icon(Icons.newspaper), label: s.newsTab),
                  ],
                ),
        );
      },
    );
  }
}
