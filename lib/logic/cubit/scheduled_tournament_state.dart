part of 'scheduled_tournament_cubit.dart';

class ScheduledTournamentState {}

class ScheduledTournamentFetching extends ScheduledTournamentState {}

class ScheduledTournamentFetched extends ScheduledTournamentState {
  final Tournament tournament;

  ScheduledTournamentFetched(this.tournament);
}

class TournamentNotFound extends ScheduledTournamentState {}