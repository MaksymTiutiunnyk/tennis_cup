// ignore: constant_identifier_names
enum Sex { All, Men, Women }

class Player {
  final String name;
  final String surname;
  final Sex sex;

  Player({required this.name, required this.surname, this.sex = Sex.Men});

  String get fullName {
    return '$surname $name';
  }
}
