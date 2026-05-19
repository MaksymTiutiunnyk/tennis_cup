import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/ui/core/widgets/custom_navigator_observer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

part 'video_player_state.dart';

class VideoPlayerCubit extends Cubit<VideoPlayerState> {
  VideoPlayerCubit() : super(PlayerStopped()) {
    CustomNavigatorObserver.stopPlayerCallback = stopPlayer;
  }

  void runFullScreenPlayer(Match match, String youTubeUrl, int startAt) {
    state.youtubePlayerController?.dispose();
    final videoId = YoutubePlayer.convertUrlToId(youTubeUrl) ?? '';
    var controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        startAt: startAt,
        enableCaption: false,
      ),
    );
    emit(PlayerFullScreenRunning(controller, match, youTubeUrl));
  }

  void runPlayer(Match match, String youTubeUrl, int startAt) {
    state.youtubePlayerController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final videoId = YoutubePlayer.convertUrlToId(youTubeUrl) ?? '';
    var controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        startAt: startAt,
        enableCaption: false,
      ),
    );
    emit(PlayerRunning(controller, match, youTubeUrl));
  }

  void stopPlayer() {
    if (state is PlayerStopped) return;
    state.youtubePlayerController?.dispose();
    emit(PlayerStopped());
  }

  @override
  Future<void> close() {
    state.youtubePlayerController?.dispose();
    return super.close();
  }
}
