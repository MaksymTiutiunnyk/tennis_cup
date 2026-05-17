import 'dart:typed_data';

import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/models/user.dart';

abstract interface class IPlayerService {
  Future<PageResult<User>> fetchRankingPlayers({
    required PageRequest page,
    Gender? genderFilter,
  });

  Future<List<User>> searchPlayersByName({
    required String query,
    String? gender,
  });

  Future<User> fetchPlayerById(int id);

  Future<void> updateProfile(int id, Map<String, dynamic> fields);

  Future<String> uploadAvatar(int id, Uint8List bytes);

  Future<void> removeAvatar(int id);
}
