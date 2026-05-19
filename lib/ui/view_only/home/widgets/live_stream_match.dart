import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/core/themes/color_utils.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/live_match_cubit.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/video_player_cubit.dart';
import 'package:tennis_cup/ui/view_only/home/widgets/live_stream_match_player.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arena_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/schedule_date_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/time_filter_cubit.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

final _dateFormatter = DateFormat('yyyy-MM-dd');

class LiveStreamMatch extends StatelessWidget {
  final Match match;

  const LiveStreamMatch({super.key, required this.match});

  String _genderLabel(S s, String gender) =>
      gender.toLowerCase() == 'female' ? s.womenLabel : s.menLabel;

  String _timeLabel(S s, Time t) => switch (t) {
        Time.Morning => s.timeLabelMorning,
        Time.Day => s.timeLabelDay,
        Time.Evening => s.timeLabelEvening,
        Time.Night => s.timeLabelNight,
        Time.Midnight => s.timeLabelMidnight,
      };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider<LiveMatchCubit>(
      create: (_) => LiveMatchCubit(
        matchId: match.id.toString(),
        matchRepository: ServiceLocator.matchRepository,
      ),
      child: BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
        builder: (context, videoState) {
          final isPlaying =
              videoState is PlayerRunning && videoState.match == match;

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
                              .selectDate(match.scheduledStart);
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
                                    color:
                                        arenaColorToMaterial(match.arenaColor),
                                    size: 8),
                                const SizedBox(width: 8),
                                Text(
                                  s.arenaFilter(match.arenaName),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            Text(
                              '${_dateFormatter.format(match.scheduledStart)} ${_genderLabel(s, match.tournamentGender)}, ${_timeLabel(s, match.tournamentTime)}',
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
                            context
                                .read<VideoPlayerCubit>()
                                .runPlayer(match, 0);
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
                            controller: videoState.youtubePlayerController!,
                          ),
                          builder: (context, player) {
                            return player;
                          },
                          onEnterFullScreen: () {
                            context
                                .read<VideoPlayerCubit>()
                                .runFullScreenPlayer(
                                  match,
                                  videoState.youtubePlayerController!.value
                                      .position.inSeconds,
                                );
                          },
                        )
                      : BlocBuilder<LiveMatchCubit, Match?>(
                          builder: (context, state) {
                            final bluePlayer =
                                state?.bluePlayer ?? match.bluePlayer;
                            final redPlayer =
                                state?.redPlayer ?? match.redPlayer;
                            final String blueLabel;
                            final String redLabel;
                            if (state != null && state.isTechnicalDefeat) {
                              blueLabel =
                                  state.winnerId == bluePlayer.id ? 'W' : 'L';
                              redLabel =
                                  state.winnerId == redPlayer.id ? 'W' : 'L';
                            } else {
                              blueLabel = (state?.blueScore ?? match.blueScore)
                                  .toString();
                              redLabel = (state?.redScore ?? match.redScore)
                                  .toString();
                            }
                            return Container(
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
                                    player: bluePlayer,
                                    label: blueLabel,
                                  ),
                                  const SizedBox(height: 16),
                                  LiveStreamMatchPlayer(
                                    player: redPlayer,
                                    label: redLabel,
                                  ),
                                ],
                              ),
                            );
                          },
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
