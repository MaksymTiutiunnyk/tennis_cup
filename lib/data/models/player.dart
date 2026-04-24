// ignore_for_file: constant_identifier_names

enum Sex { All, Men, Women }

class Player {
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

  Player({
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

  String get fullName {
    return '$surname $name';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Player) return false;
    return playerId == other.playerId && fullName == other.fullName;
  }

  @override
  int get hashCode => Object.hash(playerId, fullName);
}
