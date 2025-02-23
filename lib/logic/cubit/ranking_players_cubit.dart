import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/data_providers/player_api.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/logic/cubit/sex_filter_cubit.dart';

part 'ranking_players_state.dart';

class RankingPlayersCubit extends Cubit<RankingPlayersState> {
  final playerRepository = const PlayerRepository(playerApi: PlayerApi());
  final SexFilterCubit sexFilterCubit;
  late StreamSubscription sexFilterSubscription;
  DocumentSnapshot? _lastDocument;

  RankingPlayersCubit({
    required this.sexFilterCubit,
  }) : super(const RankingPlayersState()) {
    sexFilterSubscription = sexFilterCubit.stream.listen((sex) {
      fetchPlayersOnSexChange(sex);
    });
  }

  Future<void> fetchPlayersOnSexChange(Sex sex, {int limit = 10}) async {
    emit(state.copyWith(isLoading: true, hasError: false));

    try {
      final result = await playerRepository.fetchRankingPlayers(
        limit: limit,
        startAfter: null,
        sexFilter: sex,
      );
      final newPlayers = result['players'] as List<Player>;
      _lastDocument = result['lastDocument'] as DocumentSnapshot?;

      emit(
        state.copyWith(
          players: newPlayers,
          isLoading: false,
          hasMore: newPlayers.isNotEmpty,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  Future<void> fetchPlayersInitially({int limit = 10}) async {
    emit(state.copyWith(isLoading: true, hasError: false));

    try {
      final result = await playerRepository.fetchRankingPlayers(
        limit: limit,
        startAfter: null,
        sexFilter: sexFilterCubit.state,
      );

      final newPlayers = result['players'] as List<Player>;
      _lastDocument = result['lastDocument'] as DocumentSnapshot?;

      emit(
        state.copyWith(
          players: newPlayers,
          isLoading: false,
          hasMore: newPlayers.isNotEmpty,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  Future<void> fetchPlayersWhenScrolled({int limit = 10}) async {
    if (state.isLoading || !state.hasMore) return;

    emit(state.copyWith(
      isLoading: true,
      hasError: false,
      isScrollFetching: true,
    ));
    try {
      final result = await playerRepository.fetchRankingPlayers(
        limit: limit,
        startAfter: _lastDocument,
        sexFilter: sexFilterCubit.state,
      );

      final newPlayers = result['players'] as List<Player>;
      _lastDocument = result['lastDocument'] as DocumentSnapshot?;

      emit(
        state.copyWith(
          players: [...state.players, ...newPlayers],
          isLoading: false,
          hasMore: newPlayers.isNotEmpty,
          isScrollFetching: false,
        ),
      );
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
