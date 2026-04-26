import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/logic/cubit/sex_filter_cubit.dart';

part 'ranking_players_state.dart';

class RankingPlayersCubit extends Cubit<RankingPlayersState> {
  final PlayerRepository playerRepository;
  final SexFilterCubit sexFilterCubit;
  late StreamSubscription sexFilterSubscription;
  PageRequest _currentPage = const PageRequest(page: 0, size: 10);

  RankingPlayersCubit({
    required this.sexFilterCubit,
    required this.playerRepository,
  }) : super(const RankingPlayersState()) {
    sexFilterSubscription = sexFilterCubit.stream.listen((sex) {
      fetchPlayersOnSexChange(sex);
    });
  }

  Future<void> fetchPlayersOnSexChange(Sex sex, {int size = 10}) async {
    _currentPage = PageRequest(page: 0, size: size);
    emit(state.copyWith(isLoading: true, hasError: false));

    try {
      final result = await playerRepository.fetchRankingPlayers(
        page: _currentPage,
        sexFilter: sex,
      );
      if (result.hasMore) _currentPage = _currentPage.next;

      emit(state.copyWith(
        players: result.items,
        isLoading: false,
        hasMore: result.hasMore,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  Future<void> fetchPlayersInitially({int size = 10}) async {
    _currentPage = PageRequest(page: 0, size: size);
    emit(state.copyWith(isLoading: true, hasError: false));

    try {
      final result = await playerRepository.fetchRankingPlayers(
        page: _currentPage,
        sexFilter: sexFilterCubit.state,
      );
      if (result.hasMore) _currentPage = _currentPage.next;

      emit(state.copyWith(
        players: result.items,
        isLoading: false,
        hasMore: result.hasMore,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  Future<void> fetchPlayersWhenScrolled() async {
    if (state.isLoading || !state.hasMore) return;

    emit(state.copyWith(
      isLoading: true,
      hasError: false,
      isScrollFetching: true,
    ));
    try {
      final result = await playerRepository.fetchRankingPlayers(
        page: _currentPage,
        sexFilter: sexFilterCubit.state,
      );
      if (result.hasMore) _currentPage = _currentPage.next;

      emit(state.copyWith(
        players: [...state.players, ...result.items],
        isLoading: false,
        hasMore: result.hasMore,
        isScrollFetching: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        isScrollFetching: false,
      ));
    }
  }

  @override
  Future<void> close() {
    sexFilterSubscription.cancel();
    return super.close();
  }
}
