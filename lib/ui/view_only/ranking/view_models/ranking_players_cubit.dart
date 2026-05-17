import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';

part 'ranking_players_state.dart';

class RankingPlayersCubit extends Cubit<RankingPlayersState> {
  final PlayerRepository playerRepository;
  PageRequest _currentPage = const PageRequest(page: 0, size: 10);
  Gender? _currentGender;

  RankingPlayersCubit({required this.playerRepository})
      : super(const RankingPlayersLoading());

  Future<void> fetchPlayers({required Gender? gender, int size = 10}) async {
    _currentGender = gender;
    _currentPage = PageRequest(page: 0, size: size);
    emit(const RankingPlayersLoading());
    try {
      final result = await playerRepository.fetchRankingPlayers(
        page: _currentPage,
        genderFilter: gender,
      );
      if (result.hasMore) _currentPage = _currentPage.next;
      if (isClosed) return;
      emit(
          RankingPlayersLoaded(players: result.items, hasMore: result.hasMore));
    } catch (_) {
      if (isClosed) return;
      emit(const RankingPlayersError());
    }
  }

  Future<void> fetchPlayersWhenScrolled() async {
    final current = state;
    if (current is! RankingPlayersLoaded || !current.hasMore) return;

    emit(RankingPlayersLoadingMore(players: current.players));
    try {
      final result = await playerRepository.fetchRankingPlayers(
        page: _currentPage,
        genderFilter: _currentGender,
      );
      if (result.hasMore) _currentPage = _currentPage.next;
      if (isClosed) return;
      emit(RankingPlayersLoaded(
        players: [...current.players, ...result.items],
        hasMore: result.hasMore,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(RankingPlayersLoaded(
        players: current.players,
        hasMore: current.hasMore,
      ));
    }
  }
}
