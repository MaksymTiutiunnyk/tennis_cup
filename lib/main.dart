import 'package:flutter/material.dart';
import 'package:tennis_cup/screens/home.dart';
import 'package:tennis_cup/screens/tabs.dart';

void main() {
  runApp(const TennisCup());
}

class TennisCup extends StatelessWidget {
  const TennisCup({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tennis Cup',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const Tabs(),
    );
  }
}
