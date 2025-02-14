import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/logic/cubit/video_player_cubit.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:tennis_cup/logic/cubit/arena_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/live_stream_match_cubit.dart';
import 'package:tennis_cup/logic/cubit/match_changes_cubit.dart';
import 'package:tennis_cup/logic/cubit/schedule_date_cubit.dart';
import 'package:tennis_cup/logic/cubit/tab_index_cubit.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/logic/cubit/time_filter_cubit.dart';
import 'package:tennis_cup/presentation/widgets/home_widgets/live_stream_match_player.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

class LiveStreamMatch extends StatefulWidget {
  final Match match;
  final Tournament tournament;

  const LiveStreamMatch(
      {super.key, required this.match, required this.tournament});

  @override
  _LiveStreamMatchState createState() => _LiveStreamMatchState();
}

class _LiveStreamMatchState extends State<LiveStreamMatch> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MatchChangesCubit>(
          create: (context) => MatchChangesCubit(widget.match),
        ),
        BlocProvider<LiveStreamMatchCubit>(
          create: (context) => LiveStreamMatchCubit(widget.match),
        ),
      ],
      child: BlocListener<MatchChangesCubit, void>(
        listener: (context, state) {
          context.read<LiveStreamMatchCubit>().fetchLiveStreamMatch(
              context.read<LiveStreamMatchCubit>().state.matchId);
        },
        child: BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
          builder: (context, state) {
            var isPlaying = false;
            var state = context.read<VideoPlayerCubit>().state;
            if (state is PlayerRunning) {
              if (state.match == widget.match) {
                isPlaying = true;
              }
            }

            return Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            context
                                .read<ScheduleDateCubit>()
                                .selectDate(widget.tournament.date);
                            context
                                .read<TimeFilterCubit>()
                                .selectTime(widget.tournament.time);
                            context
                                .read<ArenaFilterCubit>()
                                .selectArena(widget.tournament.arena);
                            context.read<TabIndexCubit>().selectTab(1);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: widget.tournament.arena.color,
                                    size: 8,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Arena: ${widget.tournament.arena.title}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              Text(
                                '${formatter.format(widget.tournament.date)} ${widget.tournament.players[0].sex.name}, ${widget.tournament.time.name} ${widget.tournament.isFinished ? '(Finished)' : ''}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (isPlaying) {
                              context.read<VideoPlayerCubit>().stopPlayer();
                            } else {
                              context.read<VideoPlayerCubit>().runPlayer(
                                  widget.match,
                                  state.youtubePlayerController != null
                                      ? state.youtubePlayerController!.value
                                          .position.inSeconds
                                      : 0);
                            }
                          },
                          icon: Icon(
                            isPlaying
                                ? Icons.play_disabled_rounded
                                : Icons.play_arrow_rounded,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: isPlaying
                        ? YoutubePlayerBuilder(
                            player: YoutubePlayer(
                              controller: state.youtubePlayerController!,
                            ),
                            builder: (context, player) {
                              return player;
                            },
                            onEnterFullScreen: () {
                              context
                                  .read<VideoPlayerCubit>()
                                  .runFullScreenPlayer(
                                    widget.match,
                                    state.youtubePlayerController!.value
                                        .position.inSeconds,
                                  );
                            },
                          )
                        : BlocBuilder<LiveStreamMatchCubit, Match>(
                            builder: (context, state) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LiveStreamMatchPlayer(
                                    player: state.bluePlayer,
                                    score: state.blueScore,
                                  ),
                                  const SizedBox(height: 16),
                                  LiveStreamMatchPlayer(
                                    player: state.redPlayer,
                                    score: state.redScore,
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
