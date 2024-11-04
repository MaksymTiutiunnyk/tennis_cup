// ignore: constant_identifier_names
enum Sex { All, Men, Women }

class Player {
  final String name;
  final String surname;

  Player({required this.name, required this.surname});

  String get fullName {
    return '$surname $name';
  }
}
