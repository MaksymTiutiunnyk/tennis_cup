import 'package:flutter/material.dart';

Color arenaColorFromString(String value) {
  switch (value.toUpperCase()) {
    case 'RED':
      return Colors.red;
    case 'GREEN':
      return Colors.green;
    case 'BLUE':
      return Colors.blue;
    case 'YELLOW':
      return Colors.yellow;
    case 'WHITE':
      return Colors.white;
    case 'BLACK':
      return Colors.black;
    case 'BROWN':
      return Colors.brown;
    default:
      return Colors.grey;
  }
}

class ArenaDto {
  final int id;
  final String name;
  final String color;
  final String? city;

  const ArenaDto({
    required this.id,
    required this.name,
    required this.color,
    this.city,
  });

  factory ArenaDto.fromJson(Map<String, dynamic> json) => ArenaDto(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        color: json['color'] as String? ?? '',
        city: json['city'] as String?,
      );
}
