part of 'tournament_schedule_preview_cubit.dart';

sealed class TournamentSchedulePreviewState {}

class TournamentSchedulePreviewLoading extends TournamentSchedulePreviewState {}

class TournamentSchedulePreviewLoaded extends TournamentSchedulePreviewState {
  final List<ScheduledMatchPreview> matches;
  TournamentSchedulePreviewLoaded(this.matches);
}

class TournamentSchedulePreviewError extends TournamentSchedulePreviewState {
  final String message;
  TournamentSchedulePreviewError(this.message);
}
