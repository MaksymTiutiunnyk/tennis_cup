import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/data/repositories/news_repository.dart';
import '../../../test/helpers/mocks.dart';
import '../../../test/helpers/fixtures.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockINewsService mockNewsService;
  late NewsRepository repository;

  setUp(() {
    mockNewsService = MockINewsService();
    repository = NewsRepository(mockNewsService);
  });

  group('fetchNewsWithinPeriod', () {
    test('calls service and maps DTOs to News', () async {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);
      final dto = aNewsDto(id: 1, title: 'Test', body: 'Body');

      when(() => mockNewsService.fetchNewsWithinPeriod(start, end))
          .thenAnswer((_) async => [dto]);

      final result = await repository.fetchNewsWithinPeriod(start, end);

      expect(result, hasLength(1));
      expect(result.first.id, 1);
      expect(result.first.title, 'Test');
      verify(() => mockNewsService.fetchNewsWithinPeriod(start, end)).called(1);
    });

    test('returns empty list when service returns empty', () async {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);

      when(() => mockNewsService.fetchNewsWithinPeriod(start, end))
          .thenAnswer((_) async => []);

      final result = await repository.fetchNewsWithinPeriod(start, end);

      expect(result, isEmpty);
    });
  });

  group('fetchInterestingNews', () {
    test('calls service and maps DTOs to News list', () async {
      final dto = aNewsDto(id: 5, importance: 'INTERESTING');

      when(() => mockNewsService.fetchInterestingNews())
          .thenAnswer((_) async => [dto]);

      final result = await repository.fetchInterestingNews();

      expect(result, hasLength(1));
      expect(result.first.isInteresting, isTrue);
      verify(() => mockNewsService.fetchInterestingNews()).called(1);
    });
  });

  group('createNews', () {
    test('calls service with all params and returns mapped News', () async {
      final timestamp = DateTime(2024, 6, 1);
      final dto = aNewsDto(
        id: 10,
        title: 'New Article',
        body: 'Content',
        newsTimestamp: timestamp,
        importance: 'STANDARD',
      );

      when(() => mockNewsService.createNews(
            title: 'New Article',
            body: 'Content',
            newsTimestamp: timestamp,
            importance: 'STANDARD',
            image: null,
          )).thenAnswer((_) async => dto);

      final result = await repository.createNews(
        title: 'New Article',
        body: 'Content',
        newsTimestamp: timestamp,
        importance: 'STANDARD',
      );

      expect(result.id, 10);
      expect(result.title, 'New Article');
      expect(result.text, 'Content');
      verify(() => mockNewsService.createNews(
            title: 'New Article',
            body: 'Content',
            newsTimestamp: timestamp,
            importance: 'STANDARD',
            image: null,
          )).called(1);
    });

    test('forwards image File to service when provided', () async {
      final timestamp = DateTime(2024, 6, 1);
      final fakeFile = File('/tmp/test_image.jpg');
      final dto = aNewsDto(id: 3);

      when(() => mockNewsService.createNews(
            title: any(named: 'title'),
            body: any(named: 'body'),
            newsTimestamp: any(named: 'newsTimestamp'),
            importance: any(named: 'importance'),
            image: fakeFile,
          )).thenAnswer((_) async => dto);

      await repository.createNews(
        title: 'Title',
        body: 'Body',
        newsTimestamp: timestamp,
        importance: 'STANDARD',
        image: fakeFile,
      );

      verify(() => mockNewsService.createNews(
            title: any(named: 'title'),
            body: any(named: 'body'),
            newsTimestamp: any(named: 'newsTimestamp'),
            importance: any(named: 'importance'),
            image: fakeFile,
          )).called(1);
    });
  });

  group('updateNews', () {
    test('calls service with all params including removeImage and returns News',
        () async {
      final dto = aNewsDto(id: 7, title: 'Updated');

      when(() => mockNewsService.updateNews(
            7,
            title: 'Updated',
            body: any(named: 'body'),
            newsTimestamp: any(named: 'newsTimestamp'),
            importance: any(named: 'importance'),
            removeImage: true,
            image: null,
          )).thenAnswer((_) async => dto);

      final result = await repository.updateNews(
        7,
        title: 'Updated',
        removeImage: true,
      );

      expect(result.id, 7);
      expect(result.title, 'Updated');
    });

    test('defaults removeImage to false when not specified', () async {
      final dto = aNewsDto(id: 3);

      when(() => mockNewsService.updateNews(
            3,
            title: any(named: 'title'),
            body: any(named: 'body'),
            newsTimestamp: any(named: 'newsTimestamp'),
            importance: any(named: 'importance'),
            removeImage: false,
            image: null,
          )).thenAnswer((_) async => dto);

      await repository.updateNews(3);

      verify(() => mockNewsService.updateNews(
            3,
            title: any(named: 'title'),
            body: any(named: 'body'),
            newsTimestamp: any(named: 'newsTimestamp'),
            importance: any(named: 'importance'),
            removeImage: false,
            image: null,
          )).called(1);
    });
  });

  group('deleteNews', () {
    test('delegates to service.deleteNews with correct id', () async {
      when(() => mockNewsService.deleteNews(42)).thenAnswer((_) async {});

      await repository.deleteNews(42);

      verify(() => mockNewsService.deleteNews(42)).called(1);
    });
  });

  group('_toNews mapping', () {
    test("importance 'INTERESTING' → isInteresting true", () async {
      final dto = aNewsDto(importance: 'INTERESTING');

      when(() => mockNewsService.fetchInterestingNews())
          .thenAnswer((_) async => [dto]);

      final result = await repository.fetchInterestingNews();

      expect(result.first.isInteresting, isTrue);
    });

    test("importance 'STANDARD' → isInteresting false", () async {
      final dto = aNewsDto(importance: 'STANDARD');

      when(() => mockNewsService.fetchInterestingNews())
          .thenAnswer((_) async => [dto]);

      final result = await repository.fetchInterestingNews();

      expect(result.first.isInteresting, isFalse);
    });

    test('imageUrl null → imageUrl empty string', () async {
      final dto = aNewsDto(imageUrl: null);

      when(() => mockNewsService.fetchInterestingNews())
          .thenAnswer((_) async => [dto]);

      final result = await repository.fetchInterestingNews();

      expect(result.first.imageUrl, '');
    });

    test('imageUrl present → imageUrl preserved', () async {
      final dto = aNewsDto(imageUrl: 'http://example.com/img.jpg');

      when(() => mockNewsService.fetchInterestingNews())
          .thenAnswer((_) async => [dto]);

      final result = await repository.fetchInterestingNews();

      expect(result.first.imageUrl, 'http://example.com/img.jpg');
    });

    test('maps dto.body to news.text and dto.newsTimestamp to news.date',
        () async {
      final timestamp = DateTime(2024, 7, 20);
      final dto = aNewsDto(body: 'The actual body text', newsTimestamp: timestamp);

      when(() => mockNewsService.fetchInterestingNews())
          .thenAnswer((_) async => [dto]);

      final result = await repository.fetchInterestingNews();

      expect(result.first.text, 'The actual body text');
      expect(result.first.date, timestamp);
    });

    test('maps News as correct type', () async {
      final dto = aNewsDto();

      when(() => mockNewsService.fetchInterestingNews())
          .thenAnswer((_) async => [dto]);

      final result = await repository.fetchInterestingNews();

      expect(result.first, isA<News>());
    });
  });
}
