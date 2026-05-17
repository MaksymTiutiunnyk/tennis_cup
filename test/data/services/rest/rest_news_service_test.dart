import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/data/services/rest/rest_news_service.dart';
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

final _newsDtoJson = <String, dynamic>{
  'id': 1,
  'title': 'T',
  'body': 'B',
  'newsTimestamp': '2024-01-15T10:00:00',
  'importance': 'STANDARD',
};

void main() {
  setUpAll(registerFallbackValues);

  late MockDio mockDio;
  late RestNewsService service;

  setUp(() {
    mockDio = MockDio();
    service = RestNewsService(mockDio);
  });

  group('fetchNewsWithinPeriod', () {
    test('gets /api/v1/news with dateFrom, dateTo and size params', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': [_newsDtoJson],
          }));

      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 2, 1);
      final result = await service.fetchNewsWithinPeriod(start, end);

      expect(result, hasLength(1));
      expect(result.first.id, 1);
      expect(result.first.title, 'T');
      // dateTo is end.subtract(Duration(days: 1)) = 2024-01-31
      verify(() => mockDio.get<Map<String, dynamic>>(
            '/api/v1/news',
            queryParameters: {
              'dateFrom': '2024-01-01',
              'dateTo': '2024-01-31',
              'size': 100,
            },
          )).called(1);
    });

    test('returns empty list when content is empty', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': <dynamic>[],
          }));

      final result = await service.fetchNewsWithinPeriod(
        DateTime(2024, 1, 1),
        DateTime(2024, 2, 1),
      );

      expect(result, isEmpty);
    });

    test('dateTo is one day before end', () async {
      final capturedParams = <Map<String, dynamic>?>[];
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((inv) async {
        capturedParams.add(
            inv.namedArguments[#queryParameters] as Map<String, dynamic>?);
        return _resp<Map<String, dynamic>>({'content': <dynamic>[]});
      });

      // end = 15th, so dateTo = 14th — no month/year boundary edge cases.
      await service.fetchNewsWithinPeriod(
        DateTime(2024, 3, 1),
        DateTime(2024, 3, 15),
      );

      expect(capturedParams.single?['dateTo'], '2024-03-14');
    });
  });

  group('fetchInterestingNews', () {
    test('gets /api/v1/news with importance=INTERESTING and size=20', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': [_newsDtoJson],
          }));

      final result = await service.fetchInterestingNews();

      expect(result, hasLength(1));
      verify(() => mockDio.get<Map<String, dynamic>>(
            '/api/v1/news',
            queryParameters: {'importance': 'INTERESTING', 'size': 20},
          )).called(1);
    });
  });

  group('createNews', () {
    test('posts FormData to /api/v1/news without image', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>(_newsDtoJson));

      final timestamp = DateTime.utc(2024, 1, 15, 10, 0, 0);
      final result = await service.createNews(
        title: 'T',
        body: 'B',
        newsTimestamp: timestamp,
        importance: 'STANDARD',
      );

      expect(result.id, 1);
      expect(result.title, 'T');

      final captured = verify(() => mockDio.post<Map<String, dynamic>>(
            '/api/v1/news',
            data: captureAny(named: 'data'),
          ))
        ..called(1);

      final formData = captured.captured.single as FormData;
      // The 'news' JSON part should be present as a file entry
      expect(formData.files.any((e) => e.key == 'news'), isTrue);
      // No 'image' part when image is null
      expect(formData.files.any((e) => e.key == 'image'), isFalse);
    });
  });

  group('deleteNews', () {
    test('deletes /api/v1/news/:id', () async {
      when(() => mockDio.delete<void>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<void>(null));

      await service.deleteNews(1);

      verify(() => mockDio.delete<void>(
            '/api/v1/news/1',
            data: any(named: 'data'),
          )).called(1);
    });

    test('propagates DioException on failure', () async {
      when(() => mockDio.delete<void>(
            any(),
            data: any(named: 'data'),
          )).thenThrow(_dioEx(statusCode: 404));

      expect(() => service.deleteNews(99), throwsA(isA<DioException>()));
    });
  });
}
