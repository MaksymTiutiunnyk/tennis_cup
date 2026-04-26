import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/features/auth/logic/auth_cubit.dart';
import 'package:tennis_cup/features/auth/presentation/auth_gate.dart';
import 'package:tennis_cup/features/player_manager/presentation/player_manager_content.dart';
import 'package:tennis_cup/logic/cubit/app_mode_cubit.dart';
import 'package:tennis_cup/logic/cubit/arena_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/live_stream_match_index_cubit.dart';
import 'package:tennis_cup/logic/cubit/player_tab_index_cubit.dart';
import 'package:tennis_cup/logic/cubit/schedule_date_cubit.dart';
import 'package:tennis_cup/logic/cubit/sex_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/tab_index_cubit.dart';
import 'package:tennis_cup/logic/cubit/time_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/video_player_cubit.dart';
import 'package:tennis_cup/main.dart';
import 'package:tennis_cup/presentation/screens/home.dart';
import 'package:tennis_cup/presentation/screens/news.dart';
import 'package:tennis_cup/presentation/screens/ranking.dart';
import 'package:tennis_cup/presentation/screens/schedule.dart';
import 'package:tennis_cup/presentation/widgets/home_widgets/mode_switcher.dart';

class Tabs extends StatelessWidget {
  final int initialTabIndex;
  final DateTime initialDate;
  final Arena initialArena;
  final Time initialTime;

  const Tabs({
    super.key,
    required this.initialTabIndex,
    required this.initialDate,
    required this.initialArena,
    required this.initialTime,
  });

  static const _viewOnlyTitles = [
    'Tennis Cup: Home page',
    'Tennis Cup: Schedule',
    'Tennis Cup: Ranking',
    'Tennis Cup: News',
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ScheduleDateCubit>(
          create: (context) => ScheduleDateCubit(initialDate),
        ),
        BlocProvider<ArenaFilterCubit>(
          create: (context) => ArenaFilterCubit(initialArena),
        ),
        BlocProvider<TimeFilterCubit>(
          create: (context) => TimeFilterCubit(initialTime),
        ),
        BlocProvider<TabIndexCubit>(
          create: (context) => TabIndexCubit(initialTabIndex),
        ),
        BlocProvider<SexFilterCubit>(
          create: (context) => SexFilterCubit(),
        ),
        BlocProvider<VideoPlayerCubit>(
          create: (context) => VideoPlayerCubit(),
        ),
        BlocProvider<LiveStreamMatchIndexCubit>(
          create: (context) => LiveStreamMatchIndexCubit(),
        ),
        BlocProvider<AppModeCubit>(
          create: (_) => AppModeCubit(),
        ),
        BlocProvider<PlayerTabIndexCubit>(
          create: (_) => PlayerTabIndexCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          context
              .findAncestorWidgetOfExactType<TennisCup>()!
              .observer
              .stopPlayerCallback = context.read<VideoPlayerCubit>().stopPlayer;

          return BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
            builder: (context, videoState) {
              final isFullscreen = videoState is PlayerFullScreenRunning;

              return BlocBuilder<AppModeCubit, AppMode>(
                builder: (context, appMode) {
                  if (appMode == AppMode.viewOnly) {
                    return BlocBuilder<TabIndexCubit, int>(
                      builder: (context, tabIndex) {
                        return Scaffold(
                          appBar: isFullscreen
                              ? null
                              : AppBar(
                                  title: Text(_viewOnlyTitles[tabIndex]),
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
                                  onTap:
                                      context.read<TabIndexCubit>().selectTab,
                                  items: const [
                                    BottomNavigationBarItem(
                                        icon: Icon(Icons.home), label: 'Home'),
                                    BottomNavigationBarItem(
                                        icon: Icon(Icons.schedule),
                                        label: 'Schedule'),
                                    BottomNavigationBarItem(
                                        icon: Icon(Icons.people),
                                        label: 'Ranking'),
                                    BottomNavigationBarItem(
                                        icon: Icon(Icons.newspaper),
                                        label: 'News'),
                                  ],
                                ),
                        );
                      },
                    );
                  }

                  // Player manager mode
                  return BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, authState) {
                      if (authState is AuthAuthenticated) {
                        return BlocBuilder<PlayerTabIndexCubit, int>(
                          builder: (context, playerTab) {
                            return Scaffold(
                              appBar: AppBar(
                                title: const Text('My Account'),
                                actions: const [ModeSwitcher()],
                              ),
                              body: PlayerManagerContent(tabIndex: playerTab),
                              bottomNavigationBar: BottomNavigationBar(
                                currentIndex: playerTab,
                                onTap: context
                                    .read<PlayerTabIndexCubit>()
                                    .selectTab,
                                items: const [
                                  BottomNavigationBarItem(
                                      icon: Icon(Icons.emoji_events_outlined),
                                      label: 'Tournaments'),
                                  BottomNavigationBarItem(
                                      icon: Icon(Icons.notifications_outlined),
                                      label: 'Notifications'),
                                  BottomNavigationBarItem(
                                      icon: Icon(Icons.settings_outlined),
                                      label: 'Settings'),
                                ],
                              ),
                            );
                          },
                        );
                      }

                      return Scaffold(
                        appBar: AppBar(
                          title: const Text('My Account'),
                          actions: const [ModeSwitcher()],
                        ),
                        body: const AuthGate(),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
