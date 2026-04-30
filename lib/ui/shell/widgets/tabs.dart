import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/main.dart';
import 'package:tennis_cup/ui/settings/view_models/app_mode_cubit.dart';
import 'package:tennis_cup/ui/shell/view_models/tab_index_cubit.dart';
import 'package:tennis_cup/ui/shell/widgets/view_tabs.dart';
import 'package:tennis_cup/ui/user/player/widgets/player_tabs.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/live_stream_match_index_cubit.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/video_player_cubit.dart';
import 'package:tennis_cup/ui/view_only/player_details/view_models/player_tab_index_cubit.dart';
import 'package:tennis_cup/ui/view_only/ranking/view_models/sex_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arena_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/schedule_date_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/time_filter_cubit.dart';

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
