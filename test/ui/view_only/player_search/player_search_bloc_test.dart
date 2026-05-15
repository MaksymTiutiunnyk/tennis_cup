import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/ui/view_only/player_search/view_models/player_search_bloc.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockPlayerRepository mockRepo;

  final player = aUser(id: 5, firstName: 'Ivan');

  setUp(() {
    mockRepo = MockPlayerRepository();
  });

  PlayerSearchBloc buildBloc() => PlayerSearchBloc(
        playerRepository: mockRepo,
        initialState: PlayersNotFound(),
      );

  group('SearchFieldChanged', () {
    blocTest<PlayerSearchBloc, PlayerSearchState>(
      "empty string emits [PlayerSearchLoading, PlayersNotFound]",
      build: buildBloc,
      act: (bloc) => bloc.add(const SearchFieldChanged('')),
      expect: () => [
        isA<PlayerSearchLoading>(),
        isA<PlayersNotFound>(),
      ],
      verify: (_) {
        verifyNever(() => mockRepo.fetchPlayersBySubstring(query: any(named: 'query')));
      },
    );

    blocTest<PlayerSearchBloc, PlayerSearchState>(
      "whitespace-only string emits [PlayerSearchLoading, PlayersNotFound]",
      build: buildBloc,
      act: (bloc) => bloc.add(const SearchFieldChanged('   ')),
      expect: () => [
        isA<PlayerSearchLoading>(),
        isA<PlayersNotFound>(),
      ],
      verify: (_) {
        verifyNever(() => mockRepo.fetchPlayersBySubstring(query: any(named: 'query')));
      },
    );

    blocTest<PlayerSearchBloc, PlayerSearchState>(
      "valid query success emits [PlayerSearchLoading, PlayerSearchLoaded]",
      setUp: () {
        when(() => mockRepo.fetchPlayersBySubstring(query: 'ivan'))
            .thenAnswer((_) async => [player]);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const SearchFieldChanged('ivan')),
      expect: () => [
        isA<PlayerSearchLoading>(),
        isA<PlayerSearchLoaded>()
            .having((s) => s.players, 'players', [player]),
      ],
    );

    blocTest<PlayerSearchBloc, PlayerSearchState>(
      "query returning empty list emits [PlayerSearchLoading, PlayersNotFound]",
      setUp: () {
        when(() => mockRepo.fetchPlayersBySubstring(query: 'xyz'))
            .thenAnswer((_) async => []);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const SearchFieldChanged('xyz')),
      expect: () => [
        isA<PlayerSearchLoading>(),
        isA<PlayersNotFound>(),
      ],
    );

    blocTest<PlayerSearchBloc, PlayerSearchState>(
      "repository throws emits [PlayerSearchLoading, PlayerSearchError]",
      setUp: () {
        when(() => mockRepo.fetchPlayersBySubstring(query: any(named: 'query')))
            .thenThrow(Exception('network error'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const SearchFieldChanged('ivan')),
      expect: () => [
        isA<PlayerSearchLoading>(),
        isA<PlayerSearchError>(),
      ],
    );
  });
}
