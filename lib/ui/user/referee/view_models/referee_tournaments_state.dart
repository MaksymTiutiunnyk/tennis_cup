part of 'referee_tournaments_cubit.dart';

sealed class RefereeTournamentsState {}

class RefereeTournamentsLoading extends RefereeTournamentsState {}

class RefereeTournamentsLoaded extends RefereeTournamentsState {
  final List<TournamentDto> tournaments;
  RefereeTournamentsLoaded(this.tournaments);
}

class RefereeTournamentsError extends RefereeTournamentsState {
  final String message;
  RefereeTournamentsError(this.message);
}
