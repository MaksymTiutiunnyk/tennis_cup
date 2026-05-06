import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/match_view.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/live_match_cubit.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/video_player_cubit.dart';
import 'package:tennis_cup/ui/view_only/home/widgets/live_stream_match_player.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arena_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/schedule_date_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/time_filter_cubit.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

final _dateFormatter = DateFormat('yyyy-MM-dd');

String _formatGender(String gender) =>
    gender.toLowerCase() == 'female' ? 'Women' : 'Men';

class LiveStreamMatch extends StatelessWidget {
  final MatchView match;

  const LiveStreamMatch({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LiveMatchCubit>(
      create: (_) => LiveMatchCubit(
        matchId: match.matchId,
        matchRepository: ServiceLocator.matchRepository,
      ),
      child: BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
        builder: (context, state) {
          var isPlaying = false;
          var state = context.read<VideoPlayerCubit>().state;
          if (state is PlayerRunning) {
            if (state.match == match) {
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
                              .selectDate(match.tournamentStart);
                          context
                              .read<TimeFilterCubit>()
                              .selectTime(match.tournamentTime);
                          context.read<ArenaFilterCubit>().selectArena(Arena(
                                id: match.arenaId,
                                title: match.arenaName,
                                color: match.arenaColor,
                              ));
                          context.go(AppRoutes.viewSchedule);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.circle,
                                    color: match.arenaColor, size: 8),
                                const SizedBox(width: 8),
                                Text(
                                  'Arena: ${match.arenaName}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            Text(
                              '${_dateFormatter.format(match.tournamentStart)} ${_formatGender(match.tournamentGender)}, ${match.tournamentTime.name}',
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
                                match,
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
                                  match,
                                  state.youtubePlayerController!.value.position
                                      .inSeconds,
                                );
                          },
                        )
                      : BlocBuilder<LiveMatchCubit, Match?>(
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
                                  player: state?.bluePlayer ?? match.bluePlayer,
                                  score: state?.blueScore ?? match.blueScore,
                                ),
                                const SizedBox(height: 16),
                                LiveStreamMatchPlayer(
                                  player: state?.redPlayer ?? match.redPlayer,
                                  score: state?.redScore ?? match.redScore,
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
    );
  }
}
