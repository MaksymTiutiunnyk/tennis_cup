import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/data/services/rest/rest_arena_service.dart';
import '../../../helpers/mocks.dart';

Response<T> _resp<T>(T data) => Response<T>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

DioException _dioEx({int statusCode = 500}) => DioException(
      requestOptions: RequestOptions(path: ''),
      response: Response(
        data: null,
        statusCode: statusCode,
        requestOptions: RequestOptions(path: ''),
      ),
      type: DioExceptionType.badResponse,
    );

final _arenaJson = <String, dynamic>{
  'id': 1,
  'name': 'Arena 1',
  'color': 'RED',
};

void main() {
  setUpAll(registerFallbackValues);

  late MockDio mockDio;
  late RestArenaService service;

  setUp(() {
    mockDio = MockDio();
    service = RestArenaService(mockDio);
  });

  group('fetchAllArenas', () {
    test('gets /api/v1/arenas and returns list of ArenaDtos', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>([_arenaJson]));

      final result = await service.fetchAllArenas();

      expect(result, hasLength(1));
      expect(result.first.id, 1);
      expect(result.first.name, 'Arena 1');
      expect(result.first.color, 'RED');
      verify(() => mockDio.get<dynamic>(
            '/api/v1/arenas',
            queryParameters: any(named: 'queryParameters'),
          )).called(1);
    });

    test('returns empty list when response is empty array', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(<dynamic>[]));

      final result = await service.fetchAllArenas();

      expect(result, isEmpty);
    });

    test('returns multiple arenas', () async {
      final arena2 = <String, dynamic>{'id': 2, 'name': 'Arena 2', 'color': 'BLUE'};
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>([_arenaJson, arena2]));

      final result = await service.fetchAllArenas();

      expect(result, hasLength(2));
      expect(result[1].id, 2);
      expect(result[1].color, 'BLUE');
    });

    test('propagates DioException on failure', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(_dioEx());

      expect(() => service.fetchAllArenas(), throwsA(isA<DioException>()));
    });
  });

  group('fetchArenaById', () {
    test('gets /api/v1/arenas/:id and returns ArenaDto', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(_arenaJson));

      final result = await service.fetchArenaById(1);

      expect(result.id, 1);
      expect(result.name, 'Arena 1');
      expect(result.color, 'RED');
      verify(() => mockDio.get<dynamic>(
            '/api/v1/arenas/1',
            queryParameters: any(named: 'queryParameters'),
          )).called(1);
    });

    test('includes optional city field when present', () async {
      final withCity = Map<String, dynamic>.from(_arenaJson)
        ..['city'] = 'Kyiv';
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(withCity));

      final result = await service.fetchArenaById(1);

      expect(result.city, 'Kyiv');
    });

    test('propagates DioException on 404', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(_dioEx(statusCode: 404));

      expect(
        () => service.fetchArenaById(999),
        throwsA(isA<DioException>()),
      );
    });
  });
}
