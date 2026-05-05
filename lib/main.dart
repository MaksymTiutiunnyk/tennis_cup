import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/core/themes/app_theme.dart';
import 'package:tennis_cup/ui/user/core/view_models/active_role_cubit.dart';
import 'package:tennis_cup/ui/core/widgets/connection_monitor.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/live_stream_match_index_cubit.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/video_player_cubit.dart';
import 'package:tennis_cup/ui/view_only/news/view_models/news_cubit.dart';
import 'package:tennis_cup/ui/view_only/ranking/view_models/sex_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arena_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/schedule_date_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/time_filter_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const TennisCup());
  });
}

class TennisCup extends StatefulWidget {
  const TennisCup({super.key});

  @override
  State<TennisCup> createState() => _TennisCupState();
}

class _TennisCupState extends State<TennisCup> {
  late final GoRouter _router;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _router = buildAppRouter(navigatorKey: _navigatorKey);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(
            authService: ServiceLocator.authService,
            tokenStore: ServiceLocator.tokenStore,
          )..checkAuthStatus(),
        ),
        BlocProvider(create: (_) => ActiveRoleCubit()),
        BlocProvider(
          create: (_) => NewsCubit(
            newsRepository: ServiceLocator.newsRepository,
          ),
        ),
        BlocProvider(
          create: (_) => ScheduleDateCubit(DateTime.now()),
        ),
        BlocProvider(
          create: (_) => ArenaFilterCubit(
            const Arena(title: '', color: Colors.grey),
          ),
        ),
        BlocProvider(
          create: (_) => TimeFilterCubit(Time.Evening),
        ),
        BlocProvider(create: (_) => SexFilterCubit()),
        BlocProvider(create: (_) => VideoPlayerCubit()),
        BlocProvider(create: (_) => LiveStreamMatchIndexCubit()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          final roleCubit = context.read<ActiveRoleCubit>();
          if (state is AuthAuthenticated) {
            roleCubit.initRoles(state.roles);
          } else if (state is AuthUnauthenticated) {
            roleCubit.initRoles([]);
          }
        },
        child: MaterialApp.router(
          title: 'Tennis Cup',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: _router,
          builder: (context, child) => ConnectionMonitor(
            navigatorKey: _navigatorKey,
            child: child!,
          ),
        ),
      ),
    );
  }
}
