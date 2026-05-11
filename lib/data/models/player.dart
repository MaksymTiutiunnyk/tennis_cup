// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';

enum Sex { All, Men, Women }

class Player extends Equatable {
  final int userId;
  final String name;
  final String surname;
  final Sex sex;
  final String? birthDate;
  final String city;
  final String country;
  final String patronymicName;
  final int tournaments;
  final int matches;
  final int wins;
  final int loses;
  final int gold;
  final int silver;
  final int bronze;
  final double rankTennis;
  final double rankUTTF;
  final String imageUrl;
  final String status;

  const Player({
    required this.userId,
    required this.name,
    required this.surname,
    required this.sex,
    this.birthDate,
    this.city = '',
    this.country = '',
    this.patronymicName = '',
    required this.tournaments,
    required this.matches,
    required this.wins,
    required this.loses,
    required this.gold,
    required this.silver,
    required this.bronze,
    required this.rankTennis,
    required this.rankUTTF,
    required this.imageUrl,
    this.status = 'ACTIVE',
  });

  int get year =>
      birthDate != null ? DateTime.tryParse(birthDate!)?.year ?? 0 : 0;

  String get place =>
      [city, country].where((s) => s.isNotEmpty).join(', ');

  String? get genderString =>
      sex == Sex.Men ? 'MALE' : sex == Sex.Women ? 'FEMALE' : null;

  String get fullName => '$surname $name';

  @override
  List<Object?> get props => [
        userId,
        name,
        surname,
        sex,
        birthDate,
        city,
        country,
        patronymicName,
        tournaments,
        matches,
        wins,
        loses,
        gold,
        silver,
        bronze,
        rankTennis,
        rankUTTF,
        imageUrl,
        status,
      ];
}
