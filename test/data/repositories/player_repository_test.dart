import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';

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
    test('delegates to service and returns PageResult<User>', () async {
      final player = aUser(id: 1);
      const page = PageRequest(page: 0, size: 20);
      final expected = PageResult(items: [player], hasMore: false);

      when(() => mockPlayerService.fetchRankingPlayers(
            page: page,
            genderFilter: null,
          )).thenAnswer((_) async => expected);

      final result = await repository.fetchRankingPlayers(page: page);

      expect(result.items, [player]);
      expect(result.hasMore, isFalse);
      verify(() => mockPlayerService.fetchRankingPlayers(
            page: page,
            genderFilter: null,
          )).called(1);
    });

    test('forwards genderFilter to service', () async {
      const page = PageRequest(page: 0, size: 10);
      const expected = PageResult<User>(items: [], hasMore: false);

      when(() => mockPlayerService.fetchRankingPlayers(
            page: page,
            genderFilter: Gender.female,
          )).thenAnswer((_) async => expected);

      await repository.fetchRankingPlayers(
          page: page, genderFilter: Gender.female);

      verify(() => mockPlayerService.fetchRankingPlayers(
            page: page,
            genderFilter: Gender.female,
          )).called(1);
    });

    test('preserves hasMore from service result', () async {
      const page = PageRequest(page: 0, size: 10);
      final expected = PageResult<User>(items: [aUser()], hasMore: true);

      when(() => mockPlayerService.fetchRankingPlayers(
            page: any(named: 'page'),
            genderFilter: any(named: 'genderFilter'),
          )).thenAnswer((_) async => expected);

      final result = await repository.fetchRankingPlayers(page: page);

      expect(result.hasMore, isTrue);
    });
  });

  group('fetchPlayersBySubstring', () {
    test('delegates to service.searchPlayersByName', () async {
      final player = aUser(id: 3, firstName: 'Ivan');

      when(() => mockPlayerService.searchPlayersByName(
            query: 'Ivan',
            gender: null,
          )).thenAnswer((_) async => [player]);

      final result = await repository.fetchPlayersBySubstring(query: 'Ivan');

      expect(result, [player]);
      verify(() => mockPlayerService.searchPlayersByName(
            query: 'Ivan',
            gender: null,
          )).called(1);
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
    test('delegates to service.fetchPlayerById', () async {
      final player = aUser(id: 7);

      when(() => mockPlayerService.fetchPlayerById(7))
          .thenAnswer((_) async => player);

      final result = await repository.fetchPlayerById(7);

      expect(result, player);
      verify(() => mockPlayerService.fetchPlayerById(7)).called(1);
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
