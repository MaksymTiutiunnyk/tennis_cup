part of 'organizer_tournaments_cubit.dart';

sealed class OrganizerTournamentsState {}

class OrgTournamentsLoading extends OrganizerTournamentsState {}

class OrgTournamentsLoaded extends OrganizerTournamentsState {
  final List<Tournament> tournaments;
  OrgTournamentsLoaded(this.tournaments);
}

class OrgTournamentsError extends OrganizerTournamentsState {
  final String message;
  OrgTournamentsError(this.message);
}
