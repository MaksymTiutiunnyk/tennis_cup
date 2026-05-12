import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/tournament_invitation.dart';
import 'package:tennis_cup/data/repositories/invitations_repository.dart';

part 'invitations_state.dart';

class InvitationsCubit extends Cubit<InvitationsState> {
  final InvitationsRepository _repository;

  InvitationsCubit(
      {required InvitationsRepository repository, required String status})
      : _repository = repository,
        super(InvitationsLoading()) {
    _load(status);
  }

  Future<void> _load(String status) async {
    try {
      final items = await _repository.fetchInvitations(status: status);
      emit(InvitationsLoaded(items));
    } catch (_) {
      emit(InvitationsError('Failed to load invitations'));
    }
  }

  Future<void> accept(String invitationId) => _removeAfter(
      invitationId, () => _repository.acceptInvitation(invitationId));

  Future<void> decline(String invitationId) => _removeAfter(
      invitationId, () => _repository.declineInvitation(invitationId));

  Future<void> _removeAfter(
      String invitationId, Future<void> Function() action) async {
    final current = state;
    if (current is! InvitationsLoaded) return;

    try {
      await action();
      final updated =
          current.items.where((i) => i.id != invitationId).toList();
      emit(InvitationsLoaded(updated));
    } catch (_) {
      emit(InvitationsError('Failed to update invitation'));
    }
  }
}
