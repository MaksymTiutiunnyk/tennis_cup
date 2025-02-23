import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/connection_monitor.dart';
import 'package:tennis_cup/custom_navigator_observer.dart';
import 'package:tennis_cup/data/data_providers/arenas.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/logic/cubit/news_period_cubit.dart';
import 'package:tennis_cup/presentation/screens/tabs.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

ColorScheme kcolorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 4, 5, 100),
);

ColorScheme kdarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 4, 5, 100),
  brightness: Brightness.dark,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((fn) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => NewsPeriodCubit()),
        ],
        child: TennisCup(),
      ),
    );
  });
}

class TennisCup extends StatelessWidget {
  TennisCup({super.key});
  final observer = CustomNavigatorObserver();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tennis Cup',
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kdarkColorScheme,
        iconTheme: const IconThemeData()
            .copyWith(color: kdarkColorScheme.onPrimaryContainer),
        iconButtonTheme: IconButtonThemeData(
          style: const ButtonStyle()
              .copyWith(visualDensity: VisualDensity.compact),
        ),
        textTheme: ThemeData().textTheme.copyWith(
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
            ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
          type: BottomNavigationBarType.fixed,
          backgroundColor: kdarkColorScheme.onSecondary,
        ),
      ),
      theme: ThemeData().copyWith(
        colorScheme: kcolorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kcolorScheme.onBackground,
          foregroundColor: kcolorScheme.background,
        ),
        iconTheme: const IconThemeData()
            .copyWith(color: kcolorScheme.onPrimaryContainer),
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
            ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
          type: BottomNavigationBarType.fixed,
          backgroundColor: kcolorScheme.onSecondary,
        ),
      ),
      home: ConnectionMonitor(
        child: Tabs(
          initialTabIndex: 0,
          initialDate: DateTime.now(),
          initialArena: arenas[1],
          initialTime: Time.Evening,
        ),
      ),
      navigatorObservers: [observer],
    );
  }
}
