part of 'referee_match_cubit.dart';

sealed class RefereeMatchState {}

class RefereeMatchLoading extends RefereeMatchState {}

class RefereeMatchError extends RefereeMatchState {
  final String message;
  RefereeMatchError(this.message);
}

class RefereeMatchReady extends RefereeMatchState {
  final Match match;
  final int? firstServerPlayerId;
  // Transient message shown as SnackBar; cleared on the next meaningful action.
  final String? notification;

  RefereeMatchReady({
    required this.match,
    this.firstServerPlayerId,
    this.notification,
  });

  User get bluePlayer => match.bluePlayer;
  User get redPlayer => match.redPlayer;

  // Cards derived from backend state
  List<MatchCard> get blueCards =>
      match.cards.where((c) => c.playerId == match.bluePlayer.id).toList();

  List<MatchCard> get redCards =>
      match.cards.where((c) => c.playerId == match.redPlayer.id).toList();

  bool get canIssueWhite =>
      !blueCards.any((c) => c.cardType == 'WHITE') ||
      !redCards.any((c) => c.cardType == 'WHITE');

  bool get canIssueYellow =>
      !blueCards.any((c) => c.cardType == 'YELLOW') ||
      !redCards.any((c) => c.cardType == 'YELLOW');

  List<int> get eligibleWhitePlayers => [
        if (!blueCards.any((c) => c.cardType == 'WHITE')) bluePlayer.id,
        if (!redCards.any((c) => c.cardType == 'WHITE')) redPlayer.id,
      ];

  List<int> get eligibleYellowPlayers => [
        if (!blueCards.any((c) => c.cardType == 'YELLOW')) bluePlayer.id,
        if (!redCards.any((c) => c.cardType == 'YELLOW')) redPlayer.id,
      ];

  // Red card requires yellow first. Only players who already have yellow are eligible.
  bool get canIssueRed =>
      blueCards.any((c) => c.cardType == 'YELLOW') ||
      redCards.any((c) => c.cardType == 'YELLOW');

  List<int> get eligibleRedPlayers => [
        if (blueCards.any((c) => c.cardType == 'YELLOW')) bluePlayer.id,
        if (redCards.any((c) => c.cardType == 'YELLOW')) redPlayer.id,
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
  int? currentServerId() {
    final firstServer = match.firstServerId ?? firstServerPlayerId;
    if (firstServer == null) return null;
    final activeSet =
        match.sets.where((s) => s.status == SetStatus.active).firstOrNull;
    if (activeSet == null) return null;
    final blueId = bluePlayer.id;
    final redId = redPlayer.id;
    final otherServer = firstServer == blueId ? redId : blueId;
    // Set starter alternates each set: odd sets (1,3,5) → firstServer, even → other.
    final setStarter = (activeSet.number % 2 == 1) ? firstServer : otherServer;
    final setOther = setStarter == blueId ? redId : blueId;
    final total = activeSet.blueScore + activeSet.redScore;
    // Before deuce (< 10-10): serve changes every 2 points.
    // At deuce (both ≥ 10): serve changes every point.
    final isDeuce = activeSet.blueScore >= 10 && activeSet.redScore >= 10;
    final changes = isDeuce ? (10 + (total - 20)) : (total ~/ 2);
    return (changes % 2 == 0) ? setStarter : setOther;
  }

  RefereeMatchReady copyWith({
    Match? match,
    int? firstServerPlayerId,
    String? notification,
  }) =>
      RefereeMatchReady(
        match: match ?? this.match,
        firstServerPlayerId: firstServerPlayerId ?? this.firstServerPlayerId,
        // notification defaults to null so it clears on every normal action
        notification: notification,
      );
}
