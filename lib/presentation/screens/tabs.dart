import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
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
import 'package:tennis_cup/presentation/screens/player_tabs.dart';
import 'package:tennis_cup/presentation/screens/view_tabs.dart';

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

          return BlocBuilder<AppModeCubit, AppMode>(
            builder: (context, mode) => mode == AppMode.viewOnly
                ? const ViewTabs()
                : const PlayerTabs(),
          );
        },
      ),
    );
  }
}
