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
  // Transient message shown as SnackBar; cleared on the next meaningful action.
  final String? notification;

  RefereeMatchReady({
    required this.match,
    required this.bluePlayer,
    required this.redPlayer,
    this.firstServerPlayerId,
    this.notification,
  });

  // Cards derived from backend state
  List<MatchCardDto> get blueCards =>
      match.cards.where((c) => c.playerId == match.bluePlayerId!).toList();

  List<MatchCardDto> get redCards =>
      match.cards.where((c) => c.playerId == match.redPlayerId!).toList();

  bool get canIssueWhite =>
      !blueCards.any((c) => c.cardType == 'WHITE') ||
      !redCards.any((c) => c.cardType == 'WHITE');

  bool get canIssueYellow =>
      !blueCards.any((c) => c.cardType == 'YELLOW') ||
      !redCards.any((c) => c.cardType == 'YELLOW');

  List<int> get eligibleWhitePlayers => [
        if (!blueCards.any((c) => c.cardType == 'WHITE')) match.bluePlayerId!,
        if (!redCards.any((c) => c.cardType == 'WHITE')) match.redPlayerId!,
      ];

  List<int> get eligibleYellowPlayers => [
        if (!blueCards.any((c) => c.cardType == 'YELLOW')) match.bluePlayerId!,
        if (!redCards.any((c) => c.cardType == 'YELLOW')) match.redPlayerId!,
      ];

  // Red card requires yellow first. Only players who already have yellow are eligible.
  bool get canIssueRed =>
      blueCards.any((c) => c.cardType == 'YELLOW') ||
      redCards.any((c) => c.cardType == 'YELLOW');

  List<int> get eligibleRedPlayers => [
        if (blueCards.any((c) => c.cardType == 'YELLOW')) match.bluePlayerId!,
        if (redCards.any((c) => c.cardType == 'YELLOW')) match.redPlayerId!,
      ];

  // Odd sets: red on left (not swapped). Even sets: blue on left (swapped).
  // 5th set extra swap when either player reaches 5 points.
  bool isDisplaySwapped(int setNumber, {int blueScore = 0, int redScore = 0}) {
    bool swapped = setNumber.isEven;
    final decidingSet = match.setsToWin * 2 - 1;
    if (setNumber == decidingSet && (blueScore >= 5 || redScore >= 5)) {
      swapped = !swapped;
    }
    return swapped;
  }

  /// Single source of truth for current server.
  /// Uses backend-confirmed firstServerId once match is active; falls back to
  /// locally-selected firstServerPlayerId before the match starts.
  int? currentServerId() {
    final firstServer = match.firstServerId ?? firstServerPlayerId;
    if (firstServer == null) return null;
    final activeSet = match.sets.where((s) => s.status == 'ACTIVE').firstOrNull;
    if (activeSet == null) return null;
    final blueId = bluePlayer.userId;
    final redId = redPlayer.userId;
    final otherServer = firstServer == blueId ? redId : blueId;
    // Set starter alternates each set: odd sets (1,3,5) → firstServer, even → other.
    final setStarter = (activeSet.number % 2 == 1) ? firstServer : otherServer;
    final setOther = setStarter == blueId ? redId : blueId;
    final total = activeSet.bluePlayerScore + activeSet.redPlayerScore;
    // Before deuce (< 10-10): serve changes every 2 points.
    // At deuce (both ≥ 10): serve changes every point.
    final isDeuce =
        activeSet.bluePlayerScore >= 10 && activeSet.redPlayerScore >= 10;
    final changes = isDeuce ? (10 + (total - 20)) : (total ~/ 2);
    return (changes % 2 == 0) ? setStarter : setOther;
  }

  RefereeMatchReady copyWith({
    MatchDto? match,
    int? firstServerPlayerId,
    String? notification,
  }) =>
      RefereeMatchReady(
        match: match ?? this.match,
        bluePlayer: bluePlayer,
        redPlayer: redPlayer,
        firstServerPlayerId: firstServerPlayerId ?? this.firstServerPlayerId,
        // notification defaults to null so it clears on every normal action
        notification: notification,
      );
}
