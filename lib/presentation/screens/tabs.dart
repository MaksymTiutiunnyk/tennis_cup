import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/logic/cubit/arena_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/live_stream_match_index_cubit.dart';
import 'package:tennis_cup/logic/cubit/video_player_cubit.dart';
import 'package:tennis_cup/logic/cubit/schedule_date_cubit.dart';
import 'package:tennis_cup/logic/cubit/sex_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/tab_index_cubit.dart';
import 'package:tennis_cup/logic/cubit/time_filter_cubit.dart';
import 'package:tennis_cup/presentation/screens/home.dart';
import 'package:tennis_cup/presentation/screens/news.dart';
import 'package:tennis_cup/presentation/screens/ranking.dart';
import 'package:tennis_cup/presentation/screens/schedule.dart';

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
      ],
      child: BlocBuilder<TabIndexCubit, int>(
        builder: (context, state) {
          Widget activePage;
          String pageTitle;

          switch (state) {
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
          return BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
            builder: (context, fullScreenState) {
              return Scaffold(
                appBar: fullScreenState is PlayerFullScreenRunning
                    ? null
                    : AppBar(title: Text(pageTitle)),
                body: activePage,
                bottomNavigationBar: fullScreenState is PlayerFullScreenRunning
                    ? null
                    : BottomNavigationBar(
                        onTap: (index) {
                          context.read<TabIndexCubit>().selectTab(index);
                        },
                        currentIndex: state,
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
      ),
    );
  }
}
