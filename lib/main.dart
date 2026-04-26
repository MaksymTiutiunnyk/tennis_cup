import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/connection_monitor.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/custom_navigator_observer.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/features/auth/logic/auth_cubit.dart';
import 'package:tennis_cup/logic/cubit/news_period_cubit.dart';
import 'package:tennis_cup/presentation/screens/tabs.dart';

ColorScheme kcolorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 4, 5, 100),
);

ColorScheme kdarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 4, 5, 100),
  brightness: Brightness.dark,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((fn) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => NewsPeriodCubit()),
          BlocProvider(
            create: (context) => AuthCubit(
              authService: ServiceLocator.authService,
              tokenStore: ServiceLocator.tokenStore,
            )..checkAuthStatus(),
          ),
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
              headlineLarge: const TextStyle(
                fontSize: 30,
                color: Colors.white,
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
          backgroundColor: kcolorScheme.onSurface,
          foregroundColor: kcolorScheme.surface,
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
              headlineLarge: const TextStyle(
                fontSize: 30,
                color: Colors.black,
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
          initialArena: Arena(title: '', color: Colors.grey),
          initialTime: Time.Evening,
        ),
      ),
      navigatorObservers: [observer],
    );
  }
}
