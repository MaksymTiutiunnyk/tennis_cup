import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/ui/view_only/news/view_models/news_cubit.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockNewsRepository mockRepo;

  final testPeriod = DateTime(2024, 3, 1);
  final news1 = aNews(id: 1, title: 'News 1');
  final news2 = aNews(id: 2, title: 'News 2', isInteresting: true);

  setUp(() {
    mockRepo = MockNewsRepository();
  });

  void stubSuccess() {
    when(() => mockRepo.fetchNewsWithinPeriod(any(), any()))
        .thenAnswer((_) async => [news1, news2]);
  }

  void stubFailure() {
    when(() => mockRepo.fetchNewsWithinPeriod(any(), any()))
        .thenAnswer((_) async => throw Exception('server error'));
  }

  NewsCubit buildCubit() => NewsCubit(newsRepository: mockRepo);

  // ── auto-init ─────────────────────────────────────────────────────────────
  // `NewsCubit` calls `fetchNews(_selectedPeriod)` synchronously in the
  // constructor. `fetchNews` immediately emits `NewsFetching` (synchronously)
  // then awaits the repo and emits `NewsFetched`/`NewsError`.
  //
  // blocTest begins stream observation *after* `build()` returns, so the
  // synchronous `NewsFetching` emit is already past the observation window.
  // Only the async `NewsFetched`/`NewsError` is seen when using `wait`.

  group('auto-init fetchNews', () {
    blocTest<NewsCubit, NewsState>(
      'success: async resolution emits NewsFetched',
      setUp: stubSuccess,
      build: buildCubit,
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<NewsFetched>()
            .having((s) => s.fetchedNews, 'fetchedNews', [news1, news2]),
      ],
    );

    blocTest<NewsCubit, NewsState>(
      'failure: async resolution emits NewsError',
      setUp: stubFailure,
      build: buildCubit,
      wait: const Duration(milliseconds: 10),
      expect: () => [isA<NewsError>()],
    );
  });

  // ── explicit fetchNews call ───────────────────────────────────────────────
  // After build, the constructor's NewsFetching is gone (synchronous).
  // With `wait`, the async NewsFetched from auto-init resolves, then the
  // delayed act fires another NewsFetching (synchronous) + NewsFetched (async).
  // Observed window: [NewsFetched(auto-init), NewsFetching(act), NewsFetched(act)].

  group('fetchNews (explicit call)', () {
    blocTest<NewsCubit, NewsState>(
      'success emits [NewsFetching(period), NewsFetched(period, news)]',
      setUp: stubSuccess,
      build: buildCubit,
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        cubit.fetchNews(testPeriod);
      },
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<NewsFetched>(), // auto-init async resolution
        isA<NewsFetching>()
            .having((s) => s.selectedPeriod, 'period', testPeriod),
        isA<NewsFetched>()
            .having((s) => s.selectedPeriod, 'period', testPeriod)
            .having((s) => s.fetchedNews, 'fetchedNews', [news1, news2]),
      ],
    );

    blocTest<NewsCubit, NewsState>(
      'failure emits [NewsFetching(period), NewsError(period)]',
      setUp: stubFailure,
      build: buildCubit,
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        cubit.fetchNews(testPeriod);
      },
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<NewsError>(), // auto-init async resolution
        isA<NewsFetching>()
            .having((s) => s.selectedPeriod, 'period', testPeriod),
        isA<NewsError>()
            .having((s) => s.selectedPeriod, 'period', testPeriod),
      ],
    );
  });

  // ── selectPeriod ──────────────────────────────────────────────────────────

  group('selectPeriod', () {
    blocTest<NewsCubit, NewsState>(
      'emits [NewsFetching(period), NewsFetched(period, news)]',
      setUp: stubSuccess,
      build: buildCubit,
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        cubit.selectPeriod(testPeriod);
      },
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<NewsFetched>(), // auto-init async resolution
        isA<NewsFetching>()
            .having((s) => s.selectedPeriod, 'period', testPeriod),
        isA<NewsFetched>()
            .having((s) => s.selectedPeriod, 'period', testPeriod)
            .having((s) => s.fetchedNews, 'fetchedNews', [news1, news2]),
      ],
    );
  });
}
