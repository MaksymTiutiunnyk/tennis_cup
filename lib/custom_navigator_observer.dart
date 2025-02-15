import 'package:flutter/material.dart';
import 'package:tennis_cup/presentation/screens/tabs.dart';

class CustomNavigatorObserver extends NavigatorObserver {
  late VoidCallback stopPlayerCallback;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);

    if (route.runtimeType.toString() == '_PopupMenuRoute<double?>') {
      return;
    }

    if (previousRoute != null) {
      if ((previousRoute.runtimeType == MaterialPageRoute<dynamic>) ||
          previousRoute.runtimeType == MaterialPageRoute<Tabs>) {
        stopPlayerCallback();
      }
    }
  }
}
