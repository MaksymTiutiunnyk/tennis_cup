import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';
import 'package:tennis_cup/data/services/dto/player_profile_dto.dart';
import 'package:tennis_cup/data/services/dto/rating_record_dto.dart';
import 'package:tennis_cup/data/services/dto/user_brief_dto.dart';

import '../../../test/helpers/fixtures.dart';
import '../../../test/helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockIPlayerService mockPlayerService;
  late PlayerRepository repository;

  setUp(() {
    mockPlayerService = MockIPlayerService();
    repository = PlayerRepository(mockPlayerService);
  });

  group('fetchRankingPlayers', () {
    test('maps RatingRecordDto items to User and preserves hasMore', () async {
      final dto = aRatingRecordDto(
        userId: 1,
        firstName: 'Ivan',
        lastName: 'Petrov',
        ratingValue: 1500.0,
        gender: 'MALE',
        city: 'Kyiv',
        country: 'Ukraine',
        birthDate: '1990-01-01',
        avatarUrl: 'https://cdn.example.com/1.jpg',
      );
      const page = PageRequest(page: 0, size: 20);

      when(() => mockPlayerService.fetchRankingPlayers(
            page: page,
            genderFilter: null,
          )).thenAnswer(
              (_) async => PageResult(items: [dto], hasMore: false));

      final result = await repository.fetchRankingPlayers(page: page);

      expect(result.items, hasLength(1));
      expect(result.items.first.id, 1);
      expect(result.items.first.firstName, 'Ivan');
      expect(result.items.first.rating, 1500.0);
      expect(result.items.first.gender, Gender.male);
      expect(result.items.first.city, 'Kyiv');
      expect(result.items.first.imageUrl, 'https://cdn.example.com/1.jpg');
      expect(result.hasMore, isFalse);
    });

    test('forwards genderFilter to service', () async {
      const page = PageRequest(page: 0, size: 10);

      when(() => mockPlayerService.fetchRankingPlayers(
            page: page,
            genderFilter: Gender.female,
          )).thenAnswer((_) async =>
              const PageResult<RatingRecordDto>(items: [], hasMore: false));

      await repository.fetchRankingPlayers(
          page: page, genderFilter: Gender.female);

      verify(() => mockPlayerService.fetchRankingPlayers(
            page: page,
            genderFilter: Gender.female,
          )).called(1);
    });

    test('preserves hasMore from service result', () async {
      const page = PageRequest(page: 0, size: 10);
      final expected =
          PageResult<RatingRecordDto>(items: [aRatingRecordDto()], hasMore: true);

      when(() => mockPlayerService.fetchRankingPlayers(
            page: any(named: 'page'),
            genderFilter: any(named: 'genderFilter'),
          )).thenAnswer((_) async => expected);

      final result = await repository.fetchRankingPlayers(page: page);

      expect(result.hasMore, isTrue);
    });
  });

  group('fetchPlayersBySubstring', () {
    test('maps PlayerSearchResultDto items to User', () async {
      final dto = aPlayerSearchResultDto(
        userId: 3,
        firstName: 'Ivan',
        avatarUrl: 'https://cdn.example.com/3.jpg',
        city: 'Kyiv',
      );

      when(() => mockPlayerService.searchPlayersByName(
            query: 'Ivan',
            gender: null,
          )).thenAnswer((_) async => [dto]);

      final result = await repository.fetchPlayersBySubstring(query: 'Ivan');

      expect(result, hasLength(1));
      expect(result.first.id, 3);
      expect(result.first.firstName, 'Ivan');
      expect(result.first.imageUrl, 'https://cdn.example.com/3.jpg');
      expect(result.first.city, 'Kyiv');
    });

    test('forwards gender parameter to service', () async {
      when(() => mockPlayerService.searchPlayersByName(
            query: 'Ana',
            gender: 'FEMALE',
          )).thenAnswer((_) async => []);

      await repository.fetchPlayersBySubstring(query: 'Ana', gender: 'FEMALE');

      verify(() => mockPlayerService.searchPlayersByName(
            query: 'Ana',
            gender: 'FEMALE',
          )).called(1);
    });
  });

  group('fetchPlayerById', () {
    test('maps PlayerProfileDto to User with statistics', () async {
      final dto = aPlayerProfileDto(
        id: 7,
        firstName: 'Ivan',
        lastName: 'Petrov',
        rating: 1500.0,
        statistics: const PlayerStatisticsDto(
          totalFinishedTournaments: 4,
          totalMatches: 10,
          wins: 7,
          losses: 3,
          firstPlaceCount: 1,
          secondPlaceCount: 2,
          thirdPlaceCount: 1,
        ),
      );

      when(() => mockPlayerService.fetchPlayerById(7))
          .thenAnswer((_) async => dto);

      final result = await repository.fetchPlayerById(7);

      expect(result.id, 7);
      expect(result.firstName, 'Ivan');
      expect(result.rating, 1500.0);
      expect(result.tournaments, 4);
      expect(result.matches, 10);
      expect(result.wins, 7);
      expect(result.losses, 3);
      expect(result.goldPlaces, 1);
      expect(result.silverPlaces, 2);
      expect(result.bronzePlaces, 1);
      verify(() => mockPlayerService.fetchPlayerById(7)).called(1);
    });

    test('zeroes stats when DTO has no statistics', () async {
      final dto = aPlayerProfileDto(id: 8);

      when(() => mockPlayerService.fetchPlayerById(8))
          .thenAnswer((_) async => dto);

      final result = await repository.fetchPlayerById(8);

      expect(result.tournaments, 0);
      expect(result.matches, 0);
      expect(result.wins, 0);
      expect(result.losses, 0);
    });

    test('propagates exceptions from service', () async {
      when(() => mockPlayerService.fetchPlayerById(999))
          .thenThrow(Exception('Not found'));

      expect(
        () => repository.fetchPlayerById(999),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('fetchUsersBatch', () {
    test('returns empty map and skips service call when ids is empty',
        () async {
      final result = await repository.fetchUsersBatch(<int>{});

      expect(result, isEmpty);
      verifyNever(() => mockPlayerService.fetchUsersBatch(any()));
    });

    test('maps UserBriefDto list to {id: User} map', () async {
      const dto1 = UserBriefDto(
        id: 1,
        firstName: 'Ivan',
        lastName: 'Petrenko',
        avatarUrl: 'https://cdn.example.com/1.jpg',
        gender: 'MALE',
        city: 'Kyiv',
        country: 'Ukraine',
        birthDate: '1990-01-01',
      );
      const dto2 = UserBriefDto(
        id: 2,
        firstName: 'Olena',
        lastName: 'Koval',
      );

      when(() => mockPlayerService.fetchUsersBatch(any()))
          .thenAnswer((_) async => [dto1, dto2]);

      final result = await repository.fetchUsersBatch({1, 2});

      expect(result.keys, unorderedEquals([1, 2]));
      expect(result[1]!.firstName, 'Ivan');
      expect(result[1]!.city, 'Kyiv');
      expect(result[1]!.imageUrl, 'https://cdn.example.com/1.jpg');
      expect(result[2]!.firstName, 'Olena');
      expect(result[2]!.imageUrl, '');
    });

    test('omits ids that are missing from the service response', () async {
      const dto = UserBriefDto(id: 1, firstName: 'A', lastName: 'B');
      when(() => mockPlayerService.fetchUsersBatch(any()))
          .thenAnswer((_) async => [dto]);

      final result = await repository.fetchUsersBatch({1, 2, 3});

      expect(result.keys, [1]);
    });
  });

  group('updateProfile', () {
    test('delegates to service.updateProfile', () async {
      final fields = <String, dynamic>{'firstName': 'Olena', 'city': 'Lviv'};

      when(() => mockPlayerService.updateProfile(5, fields))
          .thenAnswer((_) async {});

      await repository.updateProfile(5, fields);

      verify(() => mockPlayerService.updateProfile(5, fields)).called(1);
    });
  });

  group('uploadAvatar', () {
    test('delegates to service.uploadAvatar and returns URL', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);

      when(() => mockPlayerService.uploadAvatar(4, bytes))
          .thenAnswer((_) async => 'https://cdn.example.com/4.jpg');

      final result = await repository.uploadAvatar(4, bytes);

      expect(result, 'https://cdn.example.com/4.jpg');
      verify(() => mockPlayerService.uploadAvatar(4, bytes)).called(1);
    });
  });

  group('removeAvatar', () {
    test('delegates to service.removeAvatar', () async {
      when(() => mockPlayerService.removeAvatar(6)).thenAnswer((_) async {});

      await repository.removeAvatar(6);

      verify(() => mockPlayerService.removeAvatar(6)).called(1);
    });
  });
}
