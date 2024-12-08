part of 'scheduled_tournament_cubit.dart';

class ScheduledTournamentState {
  const ScheduledTournamentState();
}

class ScheduledTournamentFetching extends ScheduledTournamentState {}

class ScheduledTournamentFetched extends ScheduledTournamentState {
  final Tournament tournament;

  const ScheduledTournamentFetched(this.tournament);
}

class TournamentNotFound extends ScheduledTournamentState {}
