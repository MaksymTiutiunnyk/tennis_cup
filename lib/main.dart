import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/firebase_options.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/core/themes/app_theme.dart';
import 'package:tennis_cup/ui/core/widgets/connection_monitor.dart';
import 'package:tennis_cup/ui/notifications/view_models/notification_cubit.dart';
import 'package:tennis_cup/ui/settings/view_models/language_cubit.dart';
import 'package:tennis_cup/ui/user/core/view_models/active_role_cubit.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/live_stream_match_index_cubit.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/video_player_cubit.dart';
import 'package:tennis_cup/ui/view_only/news/view_models/news_cubit.dart';
import 'package:tennis_cup/ui/view_only/ranking/view_models/gender_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arena_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/schedule_date_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/time_filter_cubit.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
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
  String? _pendingNotificationType;
  String? _pendingNotificationRole;

  @override
  void initState() {
    super.initState();
    _router = buildAppRouter(navigatorKey: _navigatorKey);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      _setupNotificationHandlers();
    }
  }

  void _setupNotificationHandlers() {
    FirebaseMessaging.onMessage.listen((message) {
      final ctx = _navigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      final type = message.data['type'] as String?;
      final role = message.data['role'] as String?;
      final (content, hasAction) = _snackBarContent(ctx, type, role, message);
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(content),
          action: hasAction
              ? SnackBarAction(
                  label: S.of(ctx).notificationView,
                  onPressed: () => _handleNotificationTap(type, role),
                )
              : null,
          duration: const Duration(seconds: 5),
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _handleNotificationTap(
          message.data['type'] as String?,
          message.data['role'] as String?,
        );
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message == null || !mounted) return;
      final type = message.data['type'] as String?;
      if (type == null) return;
      final ctx = _navigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      if (ctx.read<AuthCubit>().state is AuthAuthenticated) {
        _handleNotificationTap(type, message.data['role'] as String?);
      } else {
        _pendingNotificationType = type;
        _pendingNotificationRole = message.data['role'] as String?;
      }
    });
  }

  (String, bool) _snackBarContent(
      BuildContext ctx, String? type, String? role, RemoteMessage message) {
    if (type == 'TOURNAMENT_INVITATION') {
      final s = S.of(ctx);
      return (
        role == 'REFEREE'
            ? s.notificationRefereeInvitation
            : s.notificationPlayerInvitation,
        true,
      );
    }
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    return (body.isNotEmpty ? '$title\n$body' : title, false);
  }

  void _handleNotificationTap(String? type, String? role) {
    if (type != 'TOURNAMENT_INVITATION') return;
    final ctx = _navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    final roleCubit = ctx.read<ActiveRoleCubit>();
    final (targetRole, targetRoute) = role == 'REFEREE'
        ? (UserRole.referee, AppRoutes.refereeInvitations)
        : (UserRole.player, AppRoutes.userInvitations);
    if (!roleCubit.state.availableRoles.contains(targetRole)) return;
    roleCubit.switchRole(targetRole);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _router.go(targetRoute);
      roleCubit.requestInvitationsReload();
    });
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
          create: (_) => NotificationCubit(
            notificationService: ServiceLocator.notificationService,
          ),
        ),
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
            const Arena(
                id: '1',
                title: 'Kyiv Yellow Arena',
                color: ArenaColor.yellow,
                city: 'Kyiv'),
          ),
        ),
        BlocProvider(
          create: (_) => TimeFilterCubit(Time.Evening),
        ),
        BlocProvider(create: (_) => GenderFilterCubit()),
        BlocProvider(create: (_) => VideoPlayerCubit()),
        BlocProvider(create: (_) => LiveStreamMatchIndexCubit()),
        BlocProvider(create: (_) => LanguageCubit()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          final roleCubit = context.read<ActiveRoleCubit>();
          final notifCubit = context.read<NotificationCubit>();
          if (state is AuthAuthenticated) {
            roleCubit.initRoles(state.roles);
            notifCubit.init();
            final pending = _pendingNotificationType;
            if (pending != null) {
              final pendingRole = _pendingNotificationRole;
              _pendingNotificationType = null;
              _pendingNotificationRole = null;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _handleNotificationTap(pending, pendingRole);
              });
            }
          } else if (state is AuthUnauthenticated) {
            roleCubit.initRoles([]);
          }
        },
        child: BlocBuilder<LanguageCubit, Locale>(
          builder: (context, locale) => MaterialApp.router(
            title: 'Tennis Cup',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            locale: locale,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            routerConfig: _router,
            builder: (context, child) => ConnectionMonitor(
              navigatorKey: _navigatorKey,
              child: child!,
            ),
          ),
        ),
      ),
    );
  }
}
