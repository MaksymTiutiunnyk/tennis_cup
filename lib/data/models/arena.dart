import 'package:flutter/material.dart';

class Arena {
  final String title;
  final Color color;
  final String? id;
  final String? city;

  Arena({required this.title, required this.color, this.id, this.city});

  factory Arena.fromJson(Map<String, dynamic> json) {
    return Arena(
      id: json['id']?.toString(),
      title: json['name'] as String,
      color: _colorFromString(json['color'] as String? ?? ''),
      city: json['city'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Arena &&
      (id != null ? id == other.id : title == other.title);

  @override
  int get hashCode => id?.hashCode ?? title.hashCode;

  static Color _colorFromString(String value) {
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
}
