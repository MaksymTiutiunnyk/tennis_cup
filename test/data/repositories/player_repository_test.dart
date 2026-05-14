import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';
import '../../../test/helpers/mocks.dart';
import '../../../test/helpers/fixtures.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockIPlayerService mockPlayerService;
  late PlayerRepository repository;

  setUp(() {
    mockPlayerService = MockIPlayerService();
    repository = PlayerRepository(mockPlayerService);
  });

  group('fetchRankingPlayers', () {
    test('delegates to service and returns PageResult<Player>', () async {
      final player = aPlayer(userId: 1);
      const page = PageRequest(page: 0, size: 20);
      final expected = PageResult(items: [player], hasMore: false);

      when(() => mockPlayerService.fetchRankingPlayers(
            page: page,
            sexFilter: null,
          )).thenAnswer((_) async => expected);

      final result =
          await repository.fetchRankingPlayers(page: page);

      expect(result.items, [player]);
      expect(result.hasMore, isFalse);
      verify(() => mockPlayerService.fetchRankingPlayers(
            page: page,
            sexFilter: null,
          )).called(1);
    });

    test('forwards sexFilter to service', () async {
      const page = PageRequest(page: 0, size: 10);
      final expected = PageResult<Player>(items: [], hasMore: false);

      when(() => mockPlayerService.fetchRankingPlayers(
            page: page,
            sexFilter: Sex.Women,
          )).thenAnswer((_) async => expected);

      await repository.fetchRankingPlayers(page: page, sexFilter: Sex.Women);

      verify(() => mockPlayerService.fetchRankingPlayers(
            page: page,
            sexFilter: Sex.Women,
          )).called(1);
    });

    test('preserves hasMore from service result', () async {
      const page = PageRequest(page: 0, size: 10);
      final expected =
          PageResult<Player>(items: [aPlayer()], hasMore: true);

      when(() => mockPlayerService.fetchRankingPlayers(
            page: any(named: 'page'),
            sexFilter: any(named: 'sexFilter'),
          )).thenAnswer((_) async => expected);

      final result =
          await repository.fetchRankingPlayers(page: page);

      expect(result.hasMore, isTrue);
    });
  });

  group('fetchPlayersBySubstring', () {
    test('delegates to service.searchPlayersByName', () async {
      final player = aPlayer(userId: 3, name: 'Ivan');

      when(() => mockPlayerService.searchPlayersByName(
            query: 'Ivan',
            gender: null,
          )).thenAnswer((_) async => [player]);

      final result =
          await repository.fetchPlayersBySubstring(query: 'Ivan');

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
      final player = aPlayer(userId: 7);

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
