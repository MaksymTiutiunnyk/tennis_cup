import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/core/themes/app_theme.dart';
import 'package:tennis_cup/ui/core/widgets/connection_monitor.dart';
import 'package:tennis_cup/ui/core/widgets/custom_navigator_observer.dart';
import 'package:tennis_cup/ui/shell/widgets/tabs.dart';
import 'package:tennis_cup/ui/view_only/news/view_models/news_cubit.dart';

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
          BlocProvider(
            create: (context) => NewsCubit(
              newsRepository: ServiceLocator.newsRepository,
            ),
          ),
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
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: ConnectionMonitor(
        child: Tabs(
          initialTabIndex: 0,
          initialDate: DateTime.now(),
          initialArena: const Arena(title: '', color: Colors.grey),
          initialTime: Time.Evening,
        ),
      ),
      navigatorObservers: [observer],
    );
  }
}
