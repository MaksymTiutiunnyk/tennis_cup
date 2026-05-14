import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/data/models/pending_user.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/models/tournament_invitation.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/data/models/user_search_result.dart';
import 'package:tennis_cup/data/services/dto/admin_dto.dart';
import 'package:tennis_cup/data/services/dto/arena_dto.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';
import 'package:tennis_cup/data/services/dto/news_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_invitation_dto.dart';

// ---- Player ----

Player aPlayer({
  int userId = 1,
  String name = 'Ivan',
  String surname = 'Petrov',
  Sex sex = Sex.Men,
  String? birthDate,
  String city = '',
  String country = '',
  String patronymicName = '',
  int tournaments = 0,
  int matches = 0,
  int wins = 0,
  int loses = 0,
  int gold = 0,
  int silver = 0,
  int bronze = 0,
  double rankTennis = 0.0,
  String imageUrl = '',
  String status = 'ACTIVE',
}) {
  return Player(
    userId: userId,
    name: name,
    surname: surname,
    sex: sex,
    birthDate: birthDate,
    city: city,
    country: country,
    patronymicName: patronymicName,
    tournaments: tournaments,
    matches: matches,
    wins: wins,
    loses: loses,
    gold: gold,
    silver: silver,
    bronze: bronze,
    rankTennis: rankTennis,
    imageUrl: imageUrl,
    status: status,
  );
}

// ---- MatchDto ----

MatchDto aMatchDto({
  int id = 1,
  int tournamentId = 10,
  int refereeId = 5,
  String status = 'ACTIVE',
  int? bluePlayerId = 1,
  int? redPlayerId = 2,
  int? winnerId,
  int? firstServerId,
  int setsToWin = 2,
  String scheduledStart = '2024-01-15T09:00:00',
  String scheduledEnd = '2024-01-15T09:30:00',
  String? actualStart,
  String? actualEnd,
  List<MatchSetDto> sets = const [],
  List<MatchCardDto> cards = const [],
}) {
  return MatchDto(
    id: id,
    tournamentId: tournamentId,
    refereeId: refereeId,
    status: status,
    bluePlayerId: bluePlayerId,
    redPlayerId: redPlayerId,
    winnerId: winnerId,
    firstServerId: firstServerId,
    setsToWin: setsToWin,
    scheduledStart: scheduledStart,
    scheduledEnd: scheduledEnd,
    actualStart: actualStart,
    actualEnd: actualEnd,
    sets: sets,
    cards: cards,
  );
}

// ---- MatchSetDto ----

MatchSetDto aMatchSetDto({
  int id = 1,
  int matchId = 1,
  int number = 1,
  int bluePlayerScore = 0,
  int redPlayerScore = 0,
  String status = 'ACTIVE',
  int? winnerId,
}) {
  return MatchSetDto(
    id: id,
    matchId: matchId,
    number: number,
    bluePlayerScore: bluePlayerScore,
    redPlayerScore: redPlayerScore,
    status: status,
    winnerId: winnerId,
  );
}

// ---- MatchCardDto ----

MatchCardDto aMatchCardDto({
  int id = 1,
  int matchId = 1,
  int playerId = 1,
  String cardType = 'YELLOW',
  String issuedAt = '2024-01-01T10:00:00',
  int? setNumber,
}) {
  return MatchCardDto(
    id: id,
    matchId: matchId,
    playerId: playerId,
    cardType: cardType,
    issuedAt: issuedAt,
    setNumber: setNumber,
  );
}

// ---- NewsDto ----

NewsDto aNewsDto({
  int id = 1,
  String title = 'Test News',
  String body = 'Body',
  DateTime? newsTimestamp,
  String importance = 'STANDARD',
  String? imageUrl,
}) {
  return NewsDto(
    id: id,
    title: title,
    body: body,
    newsTimestamp: newsTimestamp ?? DateTime(2024, 1, 1),
    importance: importance,
    imageUrl: imageUrl,
  );
}

// ---- News ----

News aNews({
  int id = 1,
  String title = 'Test News',
  String text = 'Body',
  DateTime? date,
  bool isInteresting = false,
  String imageUrl = '',
}) {
  return News(
    id: id,
    title: title,
    text: text,
    date: date ?? DateTime(2024, 1, 1),
    isInteresting: isInteresting,
    imageUrl: imageUrl,
  );
}

// ---- ArenaDto ----

ArenaDto anArenaDto({
  int id = 1,
  String name = 'Arena 1',
  String color = 'RED',
  String? city,
}) {
  return ArenaDto(id: id, name: name, color: color, city: city);
}

// ---- Arena ----

Arena anArena({
  String id = '1',
  String title = 'Arena 1',
  Color? color,
  String? city,
}) {
  return Arena(
    id: id,
    title: title,
    color: color ?? Colors.red,
    city: city,
  );
}

// ---- TournamentDto ----

TournamentDto aTournamentDto({
  int id = 1,
  String name = 'Tournament 1',
  String type = 'MORNING',
  String format = 'ROUND_ROBIN',
  String status = 'ACTIVE',
  String startTime = '2024-01-15T09:00:00',
  int arenaId = 1,
  String gender = 'MALE',
  int? refereeId,
  int requiredPlayersCount = 4,
  int setsToWin = 2,
  int matchDurationMinutes = 30,
  List<TournamentParticipantDto> participants = const [],
}) {
  return TournamentDto(
    id: id,
    name: name,
    type: type,
    format: format,
    status: status,
    startTime: startTime,
    arenaId: arenaId,
    gender: gender,
    refereeId: refereeId,
    requiredPlayersCount: requiredPlayersCount,
    setsToWin: setsToWin,
    matchDurationMinutes: matchDurationMinutes,
    participants: participants,
  );
}

// ---- PendingUser ----

PendingUser aPendingUser({
  int id = 1,
  String login = 'user@test.com',
  List<UserRole> roles = const [UserRole.player],
  DateTime? createdAt,
}) {
  return PendingUser(
    id: id,
    login: login,
    roles: roles,
    createdAt: createdAt ?? DateTime(2024, 1, 1),
  );
}

// ---- PendingUserDto ----

PendingUserDto aPendingUserDto({
  int id = 1,
  String login = 'user@test.com',
  String status = 'PENDING_APPROVAL',
  List<String> roles = const ['PLAYER'],
  String createdAt = '2024-01-01T10:00:00',
}) {
  return PendingUserDto(
    id: id,
    login: login,
    status: status,
    roles: roles,
    createdAt: createdAt,
  );
}

// ---- UserSearchDto ----

UserSearchDto aUserSearchDto({
  int userId = 1,
  String firstName = 'Ivan',
  String lastName = 'Petrov',
  List<String> roles = const ['PLAYER'],
  String? avatarUrl,
}) {
  return UserSearchDto(
    userId: userId,
    firstName: firstName,
    lastName: lastName,
    roles: roles,
    avatarUrl: avatarUrl,
  );
}

// ---- UserProfileDto ----

UserProfileDto aUserProfileDto({
  int userId = 1,
  String firstName = 'Ivan',
  String lastName = 'Petrov',
  List<String> roles = const ['PLAYER'],
  String? gender,
  String? avatarUrl,
}) {
  return UserProfileDto(
    userId: userId,
    firstName: firstName,
    lastName: lastName,
    roles: roles,
    gender: gender,
    avatarUrl: avatarUrl,
  );
}

// ---- MyInvitationDto ----

MyInvitationDto aMyInvitationDto({
  int invitationId = 1,
  int tournamentId = 1,
  String tournamentName = 'T1',
  String startTime = '2024-01-15T09:00:00',
  String role = 'PLAYER',
  String status = 'PENDING',
  String createdAt = '2024-01-01T10:00:00',
}) {
  return MyInvitationDto(
    invitationId: invitationId,
    tournamentId: tournamentId,
    tournamentName: tournamentName,
    startTime: startTime,
    role: role,
    status: status,
    createdAt: createdAt,
  );
}

// ---- TournamentInvitation ----

TournamentInvitation aTournamentInvitation({
  String id = 'inv-1',
  String tournamentId = '1',
  InvitationRole role = InvitationRole.player,
  InvitationStatus status = InvitationStatus.pending,
}) {
  return TournamentInvitation(
    id: id,
    tournamentId: tournamentId,
    tournament: Tournament(
      tournamentId: tournamentId,
      name: 'T1',
      gender: 'MALE',
      status: 'ACTIVE',
      players: const [],
      date: DateTime(2024, 1, 15),
      arena: anArena(),
      time: Time.Morning,
      points: const [],
      places: const [],
    ),
    role: role,
    status: status,
  );
}

// ---- HeadToHeadMatchDto ----

HeadToHeadMatchDto aHeadToHeadMatchDto({
  int matchId = 1,
  int tournamentId = 1,
  String? tournamentName,
  DateTime? matchDate,
  int player1SetsWon = 2,
  int player2SetsWon = 1,
  int? winnerId,
  bool technicalDefeat = false,
  List<HeadToHeadSetDto> sets = const [],
}) {
  return HeadToHeadMatchDto(
    matchId: matchId,
    tournamentId: tournamentId,
    tournamentName: tournamentName,
    matchDate: matchDate ?? DateTime(2024, 1, 15),
    player1SetsWon: player1SetsWon,
    player2SetsWon: player2SetsWon,
    winnerId: winnerId,
    technicalDefeat: technicalDefeat,
    sets: sets,
  );
}

// ---- UserSearchResult ----

UserSearchResult aUserSearchResult({
  int userId = 1,
  String firstName = 'Ivan',
  String lastName = 'Petrov',
  List<UserRole> roles = const [UserRole.player],
  String? avatarUrl,
}) {
  return UserSearchResult(
    userId: userId,
    firstName: firstName,
    lastName: lastName,
    roles: roles,
    avatarUrl: avatarUrl,
  );
}
