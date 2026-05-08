part of 'referee_match_cubit.dart';

sealed class RefereeMatchState {}

class RefereeMatchLoading extends RefereeMatchState {}

class RefereeMatchError extends RefereeMatchState {
  final String message;
  RefereeMatchError(this.message);
}

class RefereeMatchReady extends RefereeMatchState {
  final MatchDto match;
  final Player bluePlayer;
  final Player redPlayer;
  final int? firstServerPlayerId;
  final List<({int blue, int red})> scoreUndoStack;
  // Transient message shown as SnackBar; cleared on the next meaningful action.
  final String? notification;

  RefereeMatchReady({
    required this.match,
    required this.bluePlayer,
    required this.redPlayer,
    required this.scoreUndoStack,
    this.firstServerPlayerId,
    this.notification,
  });

  // Cards derived from backend state
  List<MatchCardDto> get blueCards =>
      match.cards.where((c) => c.playerId == match.bluePlayerId).toList();

  List<MatchCardDto> get redCards =>
      match.cards.where((c) => c.playerId == match.redPlayerId).toList();

  bool get canIssueWhite =>
      !blueCards.any((c) => c.cardType == 'WHITE') ||
      !redCards.any((c) => c.cardType == 'WHITE');

  bool get canIssueYellow =>
      !blueCards.any((c) => c.cardType == 'YELLOW') ||
      !redCards.any((c) => c.cardType == 'YELLOW');

  List<int> get eligibleWhitePlayers => [
        if (!blueCards.any((c) => c.cardType == 'WHITE')) match.bluePlayerId,
        if (!redCards.any((c) => c.cardType == 'WHITE')) match.redPlayerId,
      ];

  List<int> get eligibleYellowPlayers => [
        if (!blueCards.any((c) => c.cardType == 'YELLOW')) match.bluePlayerId,
        if (!redCards.any((c) => c.cardType == 'YELLOW')) match.redPlayerId,
      ];

  // Red card requires yellow first. Only players who already have yellow are eligible.
  bool get canIssueRed =>
      blueCards.any((c) => c.cardType == 'YELLOW') ||
      redCards.any((c) => c.cardType == 'YELLOW');

  List<int> get eligibleRedPlayers => [
        if (blueCards.any((c) => c.cardType == 'YELLOW')) match.bluePlayerId,
        if (redCards.any((c) => c.cardType == 'YELLOW')) match.redPlayerId,
      ];

  // Odd sets: red on left (not swapped). Even sets: blue on left (swapped).
  // 5th set extra swap when either player reaches 5 points.
  bool isDisplaySwapped(int setNumber, {int blueScore = 0, int redScore = 0}) {
    bool swapped = setNumber.isEven;
    if (setNumber == 5 && (blueScore >= 5 || redScore >= 5)) {
      swapped = !swapped;
    }
    return swapped;
  }

  int? currentServerId() {
    if (firstServerPlayerId == null) return null;
    final activeSet = match.sets.where((s) => s.status == 'ACTIVE').firstOrNull;
    if (activeSet == null) return null;
    final setIndex = activeSet.number - 1;
    final blueId = bluePlayer.userId;
    final redId = redPlayer.userId;
    final otherServerId = firstServerPlayerId == blueId ? redId : blueId;
    final gameFirstServer =
        (setIndex % 2 == 0) ? firstServerPlayerId! : otherServerId;
    final total = activeSet.bluePlayerScore + activeSet.redPlayerScore;
    final isDeuce =
        activeSet.bluePlayerScore >= 10 && activeSet.redPlayerScore >= 10;
    final pointsPerServe = isDeuce ? 1 : 2;
    final changes = total ~/ pointsPerServe;
    return (changes % 2 == 0) ? gameFirstServer : otherServerId;
  }

  RefereeMatchReady copyWith({
    MatchDto? match,
    int? firstServerPlayerId,
    List<({int blue, int red})>? scoreUndoStack,
    String? notification,
  }) =>
      RefereeMatchReady(
        match: match ?? this.match,
        bluePlayer: bluePlayer,
        redPlayer: redPlayer,
        firstServerPlayerId: firstServerPlayerId ?? this.firstServerPlayerId,
        scoreUndoStack: scoreUndoStack ?? this.scoreUndoStack,
        // notification defaults to null so it clears on every normal action
        notification: notification,
      );
}
