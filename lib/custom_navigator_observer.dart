import 'package:flutter/material.dart';
import 'package:tennis_cup/presentation/screens/tabs.dart';

class CustomNavigatorObserver extends NavigatorObserver {
  late VoidCallback stopPlayerCallback;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    print('pushed new ${route.settings.runtimeType}');
    if (route.settings.runtimeType == RouteSettings) {
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
