import 'package:flutter/material.dart';

class Arena {
  final String title;
  final Color color;
  final String? id;
  final String? city;

  Arena({required this.title, required this.color, this.id, this.city});

  @override
  bool operator ==(Object other) =>
      other is Arena &&
      (id != null ? id == other.id : title == other.title);

  @override
  int get hashCode => id?.hashCode ?? title.hashCode;
}
