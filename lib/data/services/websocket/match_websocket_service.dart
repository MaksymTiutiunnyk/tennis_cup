import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:tennis_cup/config/app_config.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';

class MatchWebSocketService {
  late final StompClient _client;
  final _controllers = <String, StreamController<MatchDto>>{};
  final _stompSubs = <String, StompUnsubscribe>{};

  MatchWebSocketService() {
    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        reconnectDelay: const Duration(seconds: 5),
        onConnect: _onConnect,
        onDisconnect: (_) => _resubscribeOnReconnect(),
        onWebSocketError: (e) {},
        onStompError: (f) {},
      ),
    );
  }

  void connect() => _client.activate();

  Stream<MatchDto> watchMatch(String matchId) {
    final controller = _controllers.putIfAbsent(matchId, () {
      return StreamController<MatchDto>.broadcast(
        onCancel: () => _unsubscribe(matchId),
      );
    });

    if (_client.connected && !_stompSubs.containsKey(matchId)) {
      _subscribe(matchId);
    }

    return controller.stream;
  }

  void _onConnect(StompFrame _) {
    for (final matchId in _controllers.keys) {
      _subscribe(matchId);
    }
  }

  void _subscribe(String matchId) {
    _stompSubs[matchId] = _client.subscribe(
      destination: '/topic/matches/$matchId',
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final dto = MatchDto.fromJson(
            jsonDecode(frame.body!) as Map<String, dynamic>,
          );
          _controllers[matchId]?.add(dto);
        } catch (_) {}
      },
    );
  }

  void _unsubscribe(String matchId) {
    _stompSubs[matchId]?.call();
    _stompSubs.remove(matchId);
    _controllers[matchId]?.close();
    _controllers.remove(matchId);
  }

  void _resubscribeOnReconnect() {
    _stompSubs.clear();
  }

  void dispose() {
    for (final unsub in _stompSubs.values) {
      unsub();
    }
    _stompSubs.clear();
    for (final c in _controllers.values) {
      c.close();
    }
    _controllers.clear();
    _client.deactivate();
  }
}
