import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/connection_monitor.dart';
import 'package:tennis_cup/logic/cubit/arena_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/news_cubit.dart';
import 'package:tennis_cup/logic/cubit/news_period_cubit.dart';
import 'package:tennis_cup/logic/cubit/schedule_date_cubit.dart';
import 'package:tennis_cup/logic/cubit/scheduled_tournament_cubit.dart';
import 'package:tennis_cup/logic/cubit/tab_index_cubit.dart';
import 'package:tennis_cup/logic/cubit/time_filter_cubit.dart';
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
          BlocProvider<TabIndexCubit>(create: (_) => TabIndexCubit()),
          BlocProvider(
            create: (context) => NewsPeriodCubit(),
          ),
          BlocProvider(
            create: (context) => NewsCubit(
                newsPeriodCubit: BlocProvider.of<NewsPeriodCubit>(context)),
          ),
          
          BlocProvider(create: (context) => ScheduleDateCubit()),
          BlocProvider(create: (context) => ArenaFilterCubit()),
          BlocProvider(create: (context) => TimeFilterCubit()),
          BlocProvider(
            create: (context) => ScheduledTournamentCubit(
                scheduleDateCubit: BlocProvider.of<ScheduleDateCubit>(context),
                arenaFilterCubit: BlocProvider.of<ArenaFilterCubit>(context),
                timeFilterCubit: BlocProvider.of<TimeFilterCubit>(context)),
          ),
        ],
        child: const ProviderScope(child: TennisCup()),
      ),
    );
  });
}

class TennisCup extends StatelessWidget {
  const TennisCup({super.key});

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
      home: const ConnectionMonitor(child: Tabs()),
    );
  }
}
