import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/services/abstract/i_notification_service.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final INotificationService _service;
  String? _currentToken;

  NotificationCubit({required INotificationService notificationService})
      : _service = notificationService,
        super(NotificationInitial());

  Future<void> init() async {
    if (!Platform.isAndroid) return;
    final settings = await FirebaseMessaging.instance.requestPermission();
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!granted) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      _currentToken = token;
      await _registerToken(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _currentToken = newToken;
      _registerToken(newToken);
    });
  }

  Future<void> unregisterDevice() async {
    final token = _currentToken;
    if (token == null) return;
    try {
      await _service.deleteDevice(token);
    } catch (_) {}
    _currentToken = null;
  }

  Future<void> _registerToken(String token) async {
    try {
      final platform = Platform.isAndroid
          ? 'ANDROID'
          : Platform.isIOS
              ? 'IOS'
              : 'WEB';
      await _service.registerDevice(token: token, platform: platform);
    } catch (_) {}
  }
}
