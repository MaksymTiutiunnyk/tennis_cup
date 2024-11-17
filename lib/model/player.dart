// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

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
  final double rankTennis;
  final double rankUTTF;
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

  factory Player.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Player(
      id: doc.id,
      bronze: data['bronze'],
      gold: data['gold'],
      name: data['name'],
      surname: data['surname'],
      imageUrl: data['imageUrl'],
      loses: data['loses'],
      matches: data['matches'],
      place: data['place'],
      rankTennis: data['rank_tennis'],
      rankUTTF: data['rank_uttf'],
      silver: data['silver'],
      tournaments: data['tournaments'],
      wins: data['wins'],
      year: data['year'],
      sex: Sex.values.firstWhere((value) => value.name == data['sex']),
    );
  }

  String get fullName {
    return '$surname $name';
  }
}
