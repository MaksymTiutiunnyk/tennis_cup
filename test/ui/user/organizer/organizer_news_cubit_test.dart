import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/organizer_news_cubit.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockNewsRepository mockRepo;

  final testPeriod = DateTime(2024, 1);
  final news1 = aNews(id: 1, title: 'First');
  final news2 = aNews(id: 2, title: 'Second');

  setUp(() {
    mockRepo = MockNewsRepository();
    // Stall the constructor's auto-load so it never completes and doesn't
    // interfere with seed-based or act-based tests.
    when(() => mockRepo.fetchNewsWithinPeriod(any(), any()))
        .thenAnswer((_) => Completer<List<News>>().future);
  });

  OrganizerNewsCubit buildCubit() =>
      OrganizerNewsCubit(repository: mockRepo);

  group('load', () {
    blocTest<OrganizerNewsCubit, OrganizerNewsState>(
      'success emits [OrgNewsLoading, OrgNewsLoaded]',
      build: buildCubit,
      act: (cubit) async {
        when(() => mockRepo.fetchNewsWithinPeriod(any(), any()))
            .thenAnswer((_) async => [news1, news2]);
        await cubit.load(testPeriod);
      },
      expect: () => [
        isA<OrgNewsLoading>(),
        isA<OrgNewsLoaded>()
            .having((s) => s.items, 'items', [news1, news2]),
      ],
    );

    blocTest<OrganizerNewsCubit, OrganizerNewsState>(
      'failure emits [OrgNewsLoading, OrgNewsError]',
      build: buildCubit,
      act: (cubit) async {
        when(() => mockRepo.fetchNewsWithinPeriod(any(), any()))
            .thenThrow(Exception('server error'));
        await cubit.load(testPeriod);
      },
      expect: () => [
        isA<OrgNewsLoading>(),
        isA<OrgNewsError>(),
      ],
    );
  });

  group('create', () {
    blocTest<OrganizerNewsCubit, OrganizerNewsState>(
      'success calls createNews then reloads',
      setUp: () {
        when(() => mockRepo.createNews(
              title: any(named: 'title'),
              body: any(named: 'body'),
              newsTimestamp: any(named: 'newsTimestamp'),
              importance: any(named: 'importance'),
              image: any(named: 'image'),
            )).thenAnswer((_) async => news1);
        when(() => mockRepo.fetchNewsWithinPeriod(any(), any()))
            .thenAnswer((_) async => [news1]);
      },
      build: buildCubit,
      act: (cubit) => cubit.create(
        title: 'T',
        body: 'B',
        newsTimestamp: testPeriod,
        importance: 'STANDARD',
      ),
      verify: (_) {
        verify(() => mockRepo.createNews(
              title: any(named: 'title'),
              body: any(named: 'body'),
              newsTimestamp: any(named: 'newsTimestamp'),
              importance: any(named: 'importance'),
              image: any(named: 'image'),
            )).called(1);
        verify(() => mockRepo.fetchNewsWithinPeriod(any(), any()))
            .called(greaterThanOrEqualTo(1));
      },
    );

    blocTest<OrganizerNewsCubit, OrganizerNewsState>(
      'failure emits OrgNewsError',
      setUp: () {
        when(() => mockRepo.createNews(
              title: any(named: 'title'),
              body: any(named: 'body'),
              newsTimestamp: any(named: 'newsTimestamp'),
              importance: any(named: 'importance'),
              image: any(named: 'image'),
            )).thenThrow(Exception('create failed'));
      },
      build: buildCubit,
      act: (cubit) => cubit.create(
        title: 'T',
        body: 'B',
        newsTimestamp: testPeriod,
        importance: 'STANDARD',
      ),
      expect: () => contains(isA<OrgNewsError>()),
    );
  });

  group('update', () {
    blocTest<OrganizerNewsCubit, OrganizerNewsState>(
      'success calls updateNews then reloads',
      setUp: () {
        when(() => mockRepo.updateNews(
              any(),
              title: any(named: 'title'),
              body: any(named: 'body'),
              newsTimestamp: any(named: 'newsTimestamp'),
              importance: any(named: 'importance'),
              removeImage: any(named: 'removeImage'),
              image: any(named: 'image'),
            )).thenAnswer((_) async => news1);
        when(() => mockRepo.fetchNewsWithinPeriod(any(), any()))
            .thenAnswer((_) async => [news1]);
      },
      build: buildCubit,
      act: (cubit) => cubit.update(1, title: 'Updated'),
      verify: (_) {
        verify(() => mockRepo.updateNews(
              any(),
              title: any(named: 'title'),
              body: any(named: 'body'),
              newsTimestamp: any(named: 'newsTimestamp'),
              importance: any(named: 'importance'),
              removeImage: any(named: 'removeImage'),
              image: any(named: 'image'),
            )).called(1);
      },
    );

    blocTest<OrganizerNewsCubit, OrganizerNewsState>(
      'failure emits OrgNewsError',
      setUp: () {
        when(() => mockRepo.updateNews(
              any(),
              title: any(named: 'title'),
              body: any(named: 'body'),
              newsTimestamp: any(named: 'newsTimestamp'),
              importance: any(named: 'importance'),
              removeImage: any(named: 'removeImage'),
              image: any(named: 'image'),
            )).thenThrow(Exception('update failed'));
      },
      build: buildCubit,
      act: (cubit) => cubit.update(1, title: 'Updated'),
      expect: () => contains(isA<OrgNewsError>()),
    );
  });

  group('delete', () {
    blocTest<OrganizerNewsCubit, OrganizerNewsState>(
      'success: optimistically removes item then confirms — no rollback',
      setUp: () {
        when(() => mockRepo.deleteNews(any())).thenAnswer((_) async {});
      },
      build: buildCubit,
      seed: () => OrgNewsLoaded(testPeriod, [news1, news2]),
      act: (cubit) => cubit.delete(news1.id),
      expect: () => [
        isA<OrgNewsLoaded>().having(
          (s) => s.items,
          'items after optimistic removal',
          [news2],
        ),
      ],
    );

    blocTest<OrganizerNewsCubit, OrganizerNewsState>(
      'failure: restores original Loaded state then emits OrgNewsError',
      setUp: () {
        when(() => mockRepo.deleteNews(any()))
            .thenThrow(Exception('delete failed'));
      },
      build: buildCubit,
      seed: () => OrgNewsLoaded(testPeriod, [news1, news2]),
      act: (cubit) => cubit.delete(news1.id),
      expect: () => [
        isA<OrgNewsLoaded>()
            .having((s) => s.items, 'items after optimistic removal', [news2]),
        isA<OrgNewsLoaded>()
            .having((s) => s.items, 'restored items', [news1, news2]),
        isA<OrgNewsError>(),
      ],
    );
  });
}
