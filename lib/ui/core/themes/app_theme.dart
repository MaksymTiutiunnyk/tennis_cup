import 'package:flutter/material.dart';

class AppTheme {
  static final ColorScheme _light = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 4, 5, 100),
  );

  static final ColorScheme _dark = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 4, 5, 100),
    brightness: Brightness.dark,
  );

  static ColorScheme get lightColorScheme => _light;
  static ColorScheme get darkColorScheme => _dark;

  static ThemeData get light => ThemeData().copyWith(
        colorScheme: _light,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: _light.onSurface,
          foregroundColor: _light.surface,
        ),
        iconTheme:
            const IconThemeData().copyWith(color: _light.onPrimaryContainer),
        iconButtonTheme: IconButtonThemeData(
          style: const ButtonStyle()
              .copyWith(visualDensity: VisualDensity.compact),
        ),
        textTheme: ThemeData().textTheme.copyWith(
              bodyLarge: const TextStyle(fontSize: 18, color: Colors.black),
              bodyMedium: const TextStyle(fontSize: 16, color: Colors.black),
              bodySmall: const TextStyle(fontSize: 14, color: Colors.grey),
              labelMedium: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 98, 98, 98),
              ),
              labelLarge: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
              headlineLarge: const TextStyle(
                fontSize: 30,
                color: Colors.black,
              ),
              headlineMedium:
                  const TextStyle(fontSize: 24, color: Colors.black),
            ),
        bottomNavigationBarTheme:
            const BottomNavigationBarThemeData().copyWith(
          type: BottomNavigationBarType.fixed,
          backgroundColor: _light.onSecondary,
        ),
      );

  static ThemeData get dark => ThemeData.dark().copyWith(
        colorScheme: _dark,
        iconTheme:
            const IconThemeData().copyWith(color: _dark.onPrimaryContainer),
        iconButtonTheme: IconButtonThemeData(
          style: const ButtonStyle()
              .copyWith(visualDensity: VisualDensity.compact),
        ),
        textTheme: ThemeData.dark().textTheme.copyWith(
              bodyLarge: const TextStyle(fontSize: 18, color: Colors.white),
              bodyMedium: const TextStyle(fontSize: 16, color: Colors.white),
              bodySmall: const TextStyle(fontSize: 14, color: Colors.grey),
              labelMedium: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 98, 98, 98),
              ),
              labelLarge: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
              headlineLarge: const TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
              headlineMedium:
                  const TextStyle(fontSize: 24, color: Colors.white),
            ),
        bottomNavigationBarTheme:
            const BottomNavigationBarThemeData().copyWith(
          type: BottomNavigationBarType.fixed,
          backgroundColor: _dark.onSecondary,
        ),
      );
}
