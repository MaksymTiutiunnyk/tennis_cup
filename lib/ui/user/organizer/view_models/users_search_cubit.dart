import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tennis_cup/data/models/combined_user.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/data/models/user_search_result.dart';
import 'package:tennis_cup/data/repositories/admin_repository.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/users_search_state.dart';

class UsersSearchCubit extends Cubit<UsersSearchState> {
  final AdminRepository _adminRepository;
  final PlayerRepository _playerRepository;

  CombinedUser? _deletedUser;
  Timer? _deleteTimer;

  UsersSearchCubit({
    required AdminRepository adminRepository,
    required PlayerRepository playerRepository,
  })  : _adminRepository = adminRepository,
        _playerRepository = playerRepository,
        super(UsersSearchIdle());

  @override
  Future<void> close() {
    _deleteTimer?.cancel();
    return super.close();
  }

  Future<void> search(String query) async {
    if (query.trim().length < 2) {
      emit(UsersSearchIdle());
      return;
    }
    emit(UsersSearchLoading());
    try {
      final (nonPlayerUsers, players) = await (
        _adminRepository.searchAllNonPlayerUsers(query.trim()),
        _playerRepository.fetchPlayersBySubstring(substring: query.trim()),
      ).wait;

      emit(UsersSearchLoaded(users: _merge(nonPlayerUsers, players)));
    } catch (e) {
      emit(UsersSearchError('Failed to search users'));
    }
  }

  static List<CombinedUser> _merge(
    List<UserSearchResult> nonPlayers,
    List<Player> players,
  ) {
    final playerByUserId = <int, Player>{
      for (final p in players)
        if (p.userId != null) p.userId!: p,
    };

    final combined = <CombinedUser>[];
    final seenIds = <int>{};

    for (final user in nonPlayers) {
      final player = playerByUserId[user.userId];
      combined.add(CombinedUser(
        userId: user.userId,
        playerId: player != null ? int.tryParse(player.playerId) : null,
        firstName: player?.name ?? user.firstName,
        lastName: player?.surname ?? user.lastName,
        avatarUrl: player?.imageUrl ?? '',
        roles: [
          ...user.roles,
          if (player != null) UserRole.player,
        ],
      ));
      seenIds.add(user.userId);
    }

    for (final player in players) {
      if (player.userId != null && !seenIds.contains(player.userId)) {
        combined.add(CombinedUser(
          userId: player.userId!,
          playerId: int.tryParse(player.playerId),
          firstName: player.name,
          lastName: player.surname,
          avatarUrl: player.imageUrl,
          roles: const [UserRole.player],
        ));
      }
    }

    return combined;
  }

  void softDelete(CombinedUser user) {
    final current = state;
    if (current is! UsersSearchLoaded) return;

    _deletedUser = user;
    _deleteTimer?.cancel();

    final updated = current.users.where((u) => u.userId != user.userId).toList();
    emit(UsersSearchLoaded(users: updated, pendingDelete: user));

    _deleteTimer = Timer(const Duration(seconds: 4), _commitDelete);
  }

  void undoDelete() {
    _deleteTimer?.cancel();
    _deleteTimer = null;

    final current = state;
    if (current is! UsersSearchLoaded || _deletedUser == null) return;

    final restored = [...current.users, _deletedUser!];
    _deletedUser = null;
    emit(UsersSearchLoaded(users: restored));
  }

  Future<void> _commitDelete() async {
    final user = _deletedUser;
    _deletedUser = null;
    if (user == null) return;
    try {
      await _adminRepository.deleteOrganizer(user.userId);
    } catch (_) {
      // Silently ignore — user already removed from UI
    }
  }

  Future<void> updatePlayer(int playerId, Map<String, dynamic> fields) async {
    await _playerRepository.updatePlayerProfileById(playerId, fields);
    final current = state;
    if (current is UsersSearchLoaded) {
      final updated = current.users.map((u) {
        if (u.playerId != playerId) return u;
        return CombinedUser(
          userId: u.userId,
          playerId: u.playerId,
          firstName: fields['firstName'] as String? ?? u.firstName,
          lastName: fields['lastName'] as String? ?? u.lastName,
          avatarUrl: u.avatarUrl,
          roles: u.roles,
        );
      }).toList();
      emit(UsersSearchLoaded(users: updated, pendingDelete: current.pendingDelete));
    }
  }

  Future<String?> uploadAvatar(int playerId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return null;

    final bytes = Uint8List.fromList(await picked.readAsBytes());
    final avatarUrl = await _playerRepository.uploadPlayerAvatar(playerId, bytes);

    final current = state;
    if (current is UsersSearchLoaded) {
      final updated = current.users.map((u) {
        return u.playerId == playerId ? u.copyWith(avatarUrl: avatarUrl) : u;
      }).toList();
      emit(UsersSearchLoaded(users: updated, pendingDelete: current.pendingDelete));
    }
    return avatarUrl;
  }
}
