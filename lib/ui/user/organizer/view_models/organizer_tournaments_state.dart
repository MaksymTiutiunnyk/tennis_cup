part of 'organizer_tournaments_cubit.dart';

sealed class OrganizerTournamentsState extends Equatable {}

class OrgTournamentsLoading extends OrganizerTournamentsState {
  @override
  List<Object?> get props => const [];
}

class OrgTournamentsLoaded extends OrganizerTournamentsState {
  final List<Tournament> tournaments;
  OrgTournamentsLoaded(this.tournaments);

  @override
  List<Object?> get props => [tournaments];
}

class OrgTournamentsError extends OrganizerTournamentsState {
  final String message;
  OrgTournamentsError(this.message);

  @override
  List<Object?> get props => [message];
}
