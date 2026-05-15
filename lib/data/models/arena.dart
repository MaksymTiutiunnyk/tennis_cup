import 'package:equatable/equatable.dart';
import 'package:tennis_cup/core/utils/enum_utils.dart';

enum ArenaColor { red, green, blue, yellow, white, black, brown, grey }

ArenaColor arenaColorFromString(String? value) =>
    enumFromString(ArenaColor.values, value, ArenaColor.grey);

class Arena extends Equatable {
  final String title;
  final ArenaColor color;
  final String id;
  final String? city;

  const Arena(
      {required this.title, required this.color, required this.id, this.city});

  @override
  List<Object?> get props => [id];
}
