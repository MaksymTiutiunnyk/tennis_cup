part of 'video_player_cubit.dart';

sealed class VideoPlayerState {
  YoutubePlayerController? youtubePlayerController;

  VideoPlayerState([this.youtubePlayerController]);
}

class PlayerStopped extends VideoPlayerState {}

class PlayerRunning extends VideoPlayerState {
  Match match;

  PlayerRunning(super.youtubePlayerController, this.match);
}

class PlayerFullScreenRunning extends VideoPlayerState {
  Match match;

  PlayerFullScreenRunning(super.youtubePlayerController, this.match);
}
