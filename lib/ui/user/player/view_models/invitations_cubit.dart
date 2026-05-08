import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/tournament_invitation.dart';
import 'package:tennis_cup/data/repositories/invitations_repository.dart';

part 'invitations_state.dart';

class InvitationsCubit extends Cubit<InvitationsState> {
  final InvitationsRepository _repository;
  final String _userId;

  InvitationsCubit({
    required InvitationsRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId,
        super(InvitationsLoading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _repository.fetchInvitations(userId: _userId);
      emit(InvitationsLoaded(items));
    } catch (_) {
      emit(InvitationsError('Failed to load invitations'));
    }
  }

  Future<void> accept(String id) =>
      _updateStatus(id, InvitationStatus.accepted);

  Future<void> decline(String id) =>
      _updateStatus(id, InvitationStatus.declined);

  Future<void> _updateStatus(String id, InvitationStatus status) async {
    final current = state;
    if (current is! InvitationsLoaded) return;

    try {
      if (status == InvitationStatus.accepted) {
        await _repository.acceptInvitation(id);
      } else {
        await _repository.declineInvitation(id);
      }
      final updated = current.items
          .map((i) => i.id == id ? i.copyWith(status: status) : i)
          .toList();
      emit(InvitationsLoaded(updated));
    } catch (_) {
      emit(InvitationsError('Failed to update invitation'));
    }
  }
}
