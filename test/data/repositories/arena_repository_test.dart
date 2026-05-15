import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/repositories/arena_repository.dart';
import '../../../test/helpers/mocks.dart';
import '../../../test/helpers/fixtures.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockIArenaService mockArenaService;
  late ArenaRepository repository;

  setUp(() {
    mockArenaService = MockIArenaService();
    repository = ArenaRepository(mockArenaService);
  });

  group('fetchAllArenas', () {
    test('calls service.fetchAllArenas and maps to Arena list', () async {
      final dto = anArenaDto(id: 1, name: 'Stadium', color: 'RED', city: 'Kyiv');

      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => [dto]);

      final result = await repository.fetchAllArenas();

      expect(result, hasLength(1));
      expect(result.first, isA<Arena>());
      verify(() => mockArenaService.fetchAllArenas()).called(1);
    });

    test('returns empty list when service returns empty', () async {
      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => []);

      final result = await repository.fetchAllArenas();

      expect(result, isEmpty);
    });

    test('maps multiple DTOs correctly', () async {
      final dtos = [
        anArenaDto(id: 1, name: 'Arena A', color: 'RED'),
        anArenaDto(id: 2, name: 'Arena B', color: 'BLUE'),
        anArenaDto(id: 3, name: 'Arena C', color: 'GREEN'),
      ];

      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => dtos);

      final result = await repository.fetchAllArenas();

      expect(result, hasLength(3));
      expect(result[0].id, '1');
      expect(result[1].id, '2');
      expect(result[2].id, '3');
    });
  });

  group('_toArena – id, name, city mapping', () {
    test('maps id as string', () async {
      final dto = anArenaDto(id: 42, name: 'My Arena', color: 'RED');

      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => [dto]);

      final result = await repository.fetchAllArenas();

      expect(result.first.id, '42');
    });

    test('maps name to title', () async {
      final dto = anArenaDto(name: 'Centre Court', color: 'RED');

      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => [dto]);

      final result = await repository.fetchAllArenas();

      expect(result.first.title, 'Centre Court');
    });

    test('maps city correctly', () async {
      final dto = anArenaDto(color: 'RED', city: 'Lviv');

      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => [dto]);

      final result = await repository.fetchAllArenas();

      expect(result.first.city, 'Lviv');
    });

    test('city is null when not provided in DTO', () async {
      final dto = anArenaDto(color: 'RED', city: null);

      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => [dto]);

      final result = await repository.fetchAllArenas();

      expect(result.first.city, isNull);
    });
  });

  group('_toArena – color mapping', () {
    Future<ArenaColor> colorFor(String colorString) async {
      final dto = anArenaDto(color: colorString);
      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => [dto]);
      final result = await repository.fetchAllArenas();
      return result.first.color;
    }

    test("'RED' → ArenaColor.red", () async {
      expect(await colorFor('RED'), ArenaColor.red);
    });

    test("'GREEN' → ArenaColor.green", () async {
      expect(await colorFor('GREEN'), ArenaColor.green);
    });

    test("'BLUE' → ArenaColor.blue", () async {
      expect(await colorFor('BLUE'), ArenaColor.blue);
    });

    test("'YELLOW' → ArenaColor.yellow", () async {
      expect(await colorFor('YELLOW'), ArenaColor.yellow);
    });

    test("'WHITE' → ArenaColor.white", () async {
      expect(await colorFor('WHITE'), ArenaColor.white);
    });

    test("'BLACK' → ArenaColor.black", () async {
      expect(await colorFor('BLACK'), ArenaColor.black);
    });

    test("'BROWN' → ArenaColor.brown", () async {
      expect(await colorFor('BROWN'), ArenaColor.brown);
    });

    test("unknown color string → ArenaColor.grey", () async {
      expect(await colorFor('PURPLE'), ArenaColor.grey);
    });

    test("empty string → ArenaColor.grey", () async {
      expect(await colorFor(''), ArenaColor.grey);
    });
  });
}
