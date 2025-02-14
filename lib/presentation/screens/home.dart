import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/logic/cubit/video_player_cubit.dart';
import 'package:tennis_cup/presentation/widgets/home_widgets/live_stream_matches.dart';
import 'package:tennis_cup/presentation/widgets/home_widgets/upcoming_matches.dart';
import 'package:tennis_cup/presentation/widgets/home_widgets/winners.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
      builder: (context, state) {
        if (state is PlayerFullScreenRunning) {
          return YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: state.youtubePlayerController!,
            ),
            builder: (context, player) => player,
            onExitFullScreen: () {
              context.read<VideoPlayerCubit>().runPlayer(
                    state.match,
                    state.youtubePlayerController!.value.position.inSeconds,
                  );
            },
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 800 && constraints.maxHeight >= 500) {
              return const Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: LiveStreamMatches(isScreenWide: true)),
                      Expanded(child: Winners(isScreenWide: true))
                    ],
                  ),
                  UpcomingMatches()
                ],
              );
            }
            if (constraints.maxHeight >= 680) {
              return const Column(
                children: [
                  LiveStreamMatches(),
                  UpcomingMatches(),
                  Winners(),
                ],
              );
            }
            return const SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LiveStreamMatches(),
                  Winners(),
                  UpcomingMatches(isScrollable: false),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void deactivate() {
    var currentController =
        context.read<VideoPlayerCubit>().state.youtubePlayerController;
    if (currentController == null) {
      super.deactivate();
      return;
    }
    context.read<VideoPlayerCubit>().state.youtubePlayerController =
        YoutubePlayerController(
      initialVideoId: currentController.initialVideoId,
      flags: YoutubePlayerFlags(
        enableCaption: false,
        startAt: currentController.value.position.inSeconds,
      ),
    );
    super.deactivate();
  }
}
