import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/ui/core/widgets/custom_navigator_observer.dart';
import 'package:tennis_cup/ui/shell/widgets/user_shell.dart';
import 'package:tennis_cup/ui/shell/widgets/view_shell.dart';
import 'package:tennis_cup/ui/user/core/widgets/settings_tab.dart';
import 'package:tennis_cup/ui/user/player/view_models/invitations_cubit.dart';
import 'package:tennis_cup/ui/user/player/widgets/tournaments_tab.dart';
import 'package:tennis_cup/ui/view_only/home/widgets/home.dart';
import 'package:tennis_cup/ui/view_only/news/widgets/news.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/widgets/players_comparison_route.dart';
import 'package:tennis_cup/ui/view_only/player_details/widgets/player_details_route.dart';
import 'package:tennis_cup/ui/view_only/ranking/widgets/ranking.dart';
import 'package:tennis_cup/ui/view_only/schedule/widgets/schedule.dart';

class AppRoutes {
  static const viewHome = '/view/home';
  static const viewSchedule = '/view/schedule';
  static const viewRanking = '/view/ranking';
  static const viewNews = '/view/news';

  static const userTournaments = '/user/tournaments';
  static const userNotifications = '/user/notifications';
  static const userSettings = '/user/settings';

  static String playerDetails(String id) => '/players/$id';
  static String playersComparison(String p1Id, String p2Id) =>
      '/comparison/$p1Id/$p2Id';
}

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.viewHome,
    observers: [CustomNavigatorObserver()],
    routes: [
      // ---------- View-only mode (4 tabs) ----------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ViewShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.viewHome,
                builder: (context, state) => const Home(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.viewSchedule,
                builder: (context, state) => const Schedule(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.viewRanking,
                builder: (context, state) => const Ranking(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.viewNews,
                builder: (context, state) => const News(),
              ),
            ],
          ),
        ],
      ),

      // ---------- User mode (3 tabs, gated by auth inside the shell) ----------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            UserShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.userTournaments,
                builder: (context, state) => BlocProvider(
                  create: (_) => InvitationsCubit(
                    repository: ServiceLocator.invitationsRepository,
                    // TODO(auth): replace with the authenticated player's id
                    // once AuthCubit exposes it (Phase B step 2).
                    playerId: '1',
                  ),
                  child: const TournamentsTab(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.userNotifications,
                builder: (context, state) =>
                    const Center(child: Text('Notifications')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.userSettings,
                builder: (context, state) => const SettingsTab(),
              ),
            ],
          ),
        ],
      ),

      // ---------- Top-level pushed routes ----------
      GoRoute(
        path: '/players/:id',
        builder: (context, state) => PlayerDetailsRoute(
          playerId: state.pathParameters['id']!,
          cached: state.extra as Player?,
        ),
      ),
      GoRoute(
        path: '/comparison/:p1Id/:p2Id',
        builder: (context, state) => PlayersComparisonRoute(
          player1Id: state.pathParameters['p1Id']!,
          player2Id: state.pathParameters['p2Id']!,
          cached: state.extra as PlayersComparisonExtra?,
        ),
      ),
    ],
  );
}
