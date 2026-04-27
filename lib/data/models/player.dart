// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';

enum Sex { All, Men, Women }

class Player extends Equatable {
  final String playerId;
  final String name;
  final String surname;
  final Sex sex;
  final int year;
  final int tournaments;
  final int matches;
  final int wins;
  final int loses;
  final String place;
  final int gold;
  final int silver;
  final int bronze;
  final double rankTennis;
  final double rankUTTF;
  final String imageUrl;
  final bool hasDetailedStats;

  const Player({
    required this.playerId,
    required this.year,
    required this.tournaments,
    required this.matches,
    required this.wins,
    required this.loses,
    required this.place,
    required this.gold,
    required this.silver,
    required this.bronze,
    required this.rankTennis,
    required this.rankUTTF,
    required this.imageUrl,
    required this.name,
    required this.surname,
    required this.sex,
    this.hasDetailedStats = true,
  });

  String get fullName => '$surname $name';

  @override
  List<Object?> get props => [
        playerId,
        name,
        surname,
        sex,
        year,
        tournaments,
        matches,
        wins,
        loses,
        place,
        gold,
        silver,
        bronze,
        rankTennis,
        rankUTTF,
        imageUrl,
        hasDetailedStats,
      ];
}
