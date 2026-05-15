import 'package:equatable/equatable.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/models/user_role.dart';

class User extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String patronymicName;
  final Gender? gender;
  final String? birthDate;
  final String city;
  final String country;
  final String imageUrl;
  final List<UserRole> roles;
  final String status;
  final String? login;
  final int tournaments;
  final int matches;
  final int wins;
  final int losses;
  final int goldPlaces;
  final int silverPlaces;
  final int bronzePlaces;
  final double rating;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.patronymicName = '',
    this.gender,
    this.birthDate,
    this.city = '',
    this.country = '',
    this.imageUrl = '',
    this.roles = const [],
    this.status = 'ACTIVE',
    this.login,
    this.tournaments = 0,
    this.matches = 0,
    this.wins = 0,
    this.losses = 0,
    this.goldPlaces = 0,
    this.silverPlaces = 0,
    this.bronzePlaces = 0,
    this.rating = 0.0,
  });

  int get year =>
      birthDate != null ? DateTime.tryParse(birthDate!)?.year ?? 0 : 0;

  String get place =>
      [city, country].where((s) => s.isNotEmpty).join(', ');

  String get fullName => '$firstName $lastName';

  String? get genderString => gender == Gender.male
      ? 'MALE'
      : gender == Gender.female
          ? 'FEMALE'
          : null;

  bool get isDeletable =>
      roles.any((r) => r == UserRole.organizer || r == UserRole.admin);

  User copyWith({String? imageUrl}) => User(
        id: id,
        firstName: firstName,
        lastName: lastName,
        patronymicName: patronymicName,
        gender: gender,
        birthDate: birthDate,
        city: city,
        country: country,
        imageUrl: imageUrl ?? this.imageUrl,
        roles: roles,
        status: status,
        login: login,
        tournaments: tournaments,
        matches: matches,
        wins: wins,
        losses: losses,
        goldPlaces: goldPlaces,
        silverPlaces: silverPlaces,
        bronzePlaces: bronzePlaces,
        rating: rating,
      );

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        patronymicName,
        gender,
        birthDate,
        city,
        country,
        imageUrl,
        roles,
        status,
        login,
        tournaments,
        matches,
        wins,
        losses,
        goldPlaces,
        silverPlaces,
        bronzePlaces,
        rating,
      ];
}
