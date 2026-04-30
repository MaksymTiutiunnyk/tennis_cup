part of 'invitations_cubit.dart';

sealed class InvitationsState {}

class InvitationsLoading extends InvitationsState {}

class InvitationsLoaded extends InvitationsState {
  final List<TournamentInvitation> items;
  InvitationsLoaded(this.items);
}

class InvitationsError extends InvitationsState {
  final String message;
  InvitationsError(this.message);
}
