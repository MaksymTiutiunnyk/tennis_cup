import 'package:flutter/material.dart';

/// NavigatorObserver attached to the root [GoRouter]. When a route is pushed
/// on top of an existing one we stop the YouTube player so it doesn't keep
/// playing audio behind a detail screen.
///
/// VideoPlayerCubit registers its [stopPlayer] handler via [stopPlayerCallback]
/// at construction time. The static field keeps the observer decoupled from
/// the cubit's location in the widget tree.
class CustomNavigatorObserver extends NavigatorObserver {
  static VoidCallback? stopPlayerCallback;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);

    if (route.runtimeType.toString() == '_PopupMenuRoute<double?>') {
      return;
    }

    if (previousRoute != null) {
      stopPlayerCallback?.call();
    }
  }
}
