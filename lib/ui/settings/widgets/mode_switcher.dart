import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/routing/app_router.dart';

enum AppMode { viewOnly, user }

class ModeSwitcher extends StatelessWidget {
  const ModeSwitcher({super.key});

  static String _lastViewRoute = AppRoutes.viewHome;
  static String _lastUserRoute = AppRoutes.userTournaments;

  AppMode _modeFromLocation(String location) {
    return location.startsWith('/user') ? AppMode.user : AppMode.viewOnly;
  }

  void _switchMode(BuildContext context, AppMode targetMode) {
    context.go(targetMode == AppMode.user ? _lastUserRoute : _lastViewRoute);
  }

  @override
  Widget build(BuildContext context) {
    final fg =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;
    final location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith('/view')) _lastViewRoute = location;
    if (location.startsWith('/user')) _lastUserRoute = location;

    final mode = _modeFromLocation(location);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SegmentedButton<AppMode>(
        segments: const [
          ButtonSegment(
            value: AppMode.viewOnly,
            icon: Icon(Icons.live_tv_outlined),
          ),
          ButtonSegment(
            value: AppMode.user,
            icon: Icon(Icons.person_outline),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (s) => _switchMode(context, s.first),
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          foregroundColor: fg,
          selectedForegroundColor: fg,
          selectedBackgroundColor: fg.withValues(alpha: 0.2),
          side: BorderSide(color: fg.withValues(alpha: 0.4)),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
