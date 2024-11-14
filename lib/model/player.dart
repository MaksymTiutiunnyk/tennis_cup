// ignore: constant_identifier_names
enum Sex { All, Men, Women }

class Player {
  final String id;
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
  final int rankTennis;
  final int rankUTTF;
  final String imageUrl;

  Player(
      {required this.id,
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
      required this.sex});

  String get fullName {
    return '$surname $name';
  }
}
