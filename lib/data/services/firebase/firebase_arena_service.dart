import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';

// Firebase had no separate arenas collection — arenas were a hardcoded list
// in the app. This implementation fulfills IArenaService by returning that
// same static list, keeping the interface contract consistent with REST.
class FirebaseArenaService implements IArenaService {
  const FirebaseArenaService();

  @override
  Future<List<Arena>> fetchAllArenas() async => [
        const Arena(title: 'Australia', color: Colors.green),
        const Arena(title: 'Europe', color: Color.fromARGB(255, 4, 6, 114)),
        const Arena(title: 'Beijing', color: Colors.greenAccent),
        const Arena(title: 'America', color: Colors.red),
        const Arena(title: 'Africa', color: Colors.black),
        const Arena(title: 'Asia', color: Colors.yellowAccent),
        const Arena(title: 'Montreal', color: Color.fromARGB(255, 30, 118, 8)),
        const Arena(
            title: 'New Delhi', color: Color.fromARGB(255, 123, 158, 41)),
        const Arena(title: 'Rio', color: Color.fromARGB(255, 51, 50, 50)),
        const Arena(title: 'Mexico', color: Color.fromARGB(255, 95, 15, 10)),
        const Arena(title: 'Rome', color: Color.fromARGB(255, 172, 52, 9)),
        const Arena(title: 'Paris', color: Color.fromARGB(255, 29, 186, 214)),
        const Arena(title: 'Prague', color: Color.fromARGB(255, 189, 190, 135)),
        const Arena(title: 'Seoul', color: Colors.orange),
        const Arena(title: 'Tokyo', color: Color.fromARGB(255, 162, 0, 191)),
        const Arena(title: 'London', color: Color.fromARGB(255, 135, 34, 128))
      ];
}
