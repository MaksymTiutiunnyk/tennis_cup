import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/arena.dart';

Color arenaColorToMaterial(ArenaColor color) => switch (color) {
      ArenaColor.red => Colors.red,
      ArenaColor.green => Colors.green,
      ArenaColor.blue => Colors.blue,
      ArenaColor.yellow => Colors.yellow,
      ArenaColor.white => Colors.white,
      ArenaColor.black => Colors.black,
      ArenaColor.brown => Colors.brown,
      ArenaColor.grey => Colors.grey,
    };
