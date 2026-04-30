import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:tennis_cup/data/models/match.dart';

part 'video_player_state.dart';

class VideoPlayerCubit extends Cubit<VideoPlayerState> {
  VideoPlayerCubit() : super(PlayerStopped());

  void runFullScreenPlayer(Match match, int startAt) {
    var controller = YoutubePlayerController(
      initialVideoId: 'oZhjLx2tsLM',
      flags: YoutubePlayerFlags(
        startAt: startAt,
        enableCaption: false,
      ),
    );
    emit(PlayerFullScreenRunning(controller, match));
  }

  void runPlayer(Match match, int startAt) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    var controller = YoutubePlayerController(
      initialVideoId: 'oZhjLx2tsLM',
      flags: YoutubePlayerFlags(
        startAt: startAt,
        enableCaption: false,
      ),
    );
    emit(PlayerRunning(controller, match));
  }

  void stopPlayer() {
    if (state is PlayerStopped) {
      return;
    }
    emit(PlayerStopped());
  }

  @override
  Future<void> close() {
    state.youtubePlayerController?.dispose();
    return super.close();
  }
}
