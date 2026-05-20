import 'dart:typed_data';

import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/services/dto/rating_record_dto.dart';
import 'package:tennis_cup/data/services/dto/player_profile_dto.dart';
import 'package:tennis_cup/data/services/dto/player_search_result_dto.dart';
import 'package:tennis_cup/data/services/dto/user_brief_dto.dart';

abstract interface class IPlayerService {
  Future<PageResult<RatingRecordDto>> fetchRankingPlayers({
    required PageRequest page,
    Gender? genderFilter,
  });

  Future<List<PlayerSearchResultDto>> searchPlayersByName({
    required String query,
    String? gender,
  });

  Future<PlayerProfileDto> fetchPlayerById(int id);

  Future<List<UserBriefDto>> fetchUsersBatch(List<int> userIds);

  Future<void> updateProfile(int id, Map<String, dynamic> fields);

  Future<String> uploadAvatar(int id, Uint8List bytes);

  Future<void> removeAvatar(int id);
}
