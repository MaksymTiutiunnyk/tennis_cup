import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';

class LiveStreamMatchCubit extends Cubit<Match?> {
  final MatchRepository matchRepository;

  LiveStreamMatchCubit({required this.matchRepository}) : super(null);

  void fetchLiveStreamMatch(String matchId) async {
    final match = await matchRepository.fetchMatchById(matchId: matchId);
    emit(match);
  }
}
