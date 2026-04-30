import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Arena extends Equatable {
  final String title;
  final Color color;
  final String? id;
  final String? city;

  const Arena({required this.title, required this.color, this.id, this.city});

  @override
  List<Object?> get props => [id, title, color, city];
}
