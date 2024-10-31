import 'package:tennis_cup/data/players.dart';
import 'package:tennis_cup/data/tournaments.dart';
import 'package:tennis_cup/model/match.dart';

final List<Match> matches = [
  Match(
    bluePlayer: players[1],
    redPlayer: players[2],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      13,
      40,
    ),
  ),
  Match(
    bluePlayer: players[0],
    redPlayer: players[3],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      14,
      10,
    ),
  ),
  Match(
    bluePlayer: players[4],
    redPlayer: players[5],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      14,
      40,
    ),
  ),
  Match(
    bluePlayer: players[1],
    redPlayer: players[3],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      15,
      10,
    ),
  ),
  Match(
    bluePlayer: players[5],
    redPlayer: players[2],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      15,
      40,
    ),
  ),
  Match(
    bluePlayer: players[0],
    redPlayer: players[4],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      16,
      10,
    ),
  ),
  Match(
    bluePlayer: players[1],
    redPlayer: players[5],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      16,
      40,
    ),
  ),
  Match(
    bluePlayer: players[4],
    redPlayer: players[3],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      17,
      10,
    ),
  ),
  Match(
    bluePlayer: players[0],
    redPlayer: players[2],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      17,
      40,
    ),
  ),
  Match(
    bluePlayer: players[1],
    redPlayer: players[4],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      18,
      10,
    ),
  ),
  Match(
    bluePlayer: players[0],
    redPlayer: players[5],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      18,
      40,
    ),
  ),
  Match(
    bluePlayer: players[3],
    redPlayer: players[2],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      19,
      10,
    ),
  ),
  Match(
    bluePlayer: players[1],
    redPlayer: players[0],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      19,
      40,
    ),
  ),
  Match(
    bluePlayer: players[4],
    redPlayer: players[2],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      20,
      10,
    ),
  ),
  Match(
    bluePlayer: players[5],
    redPlayer: players[3],
    tournament: tournaments[0],
    dateTime: DateTime(
      tournaments[0].date.year,
      tournaments[0].date.month,
      tournaments[0].date.day,
      20,
      40,
    ),
  ),


  // Match(
  //   bluePlayer: players[6],
  //   redPlayer: players[7],
  //   tournament: arenas[4],
  //   dateTime: DateTime(2024, 10, 28, 11, 35),
  // ),
  // Match(
  //   bluePlayer: Player(name: 'Volodymyr', surname: 'Ivasiv'),
  //   redPlayer: Player(name: 'Mykola', surname: 'Slozka'),
  //   arena: Arena(title: 'Beijing', color: Colors.purple),
  //   dateTime: DateTime(2024, 10, 28, 11, 35),
  // ),
  // Match(
  //   bluePlayer: Player(name: 'Olena', surname: 'Telezhynska'),
  //   redPlayer: Player(name: 'Svitlana', surname: 'Yureneva'),
  //   arena: Arena(title: 'Australia', color: Colors.green),
  //   dateTime: DateTime(2024, 10, 28, 11, 50),
  // ),
];
