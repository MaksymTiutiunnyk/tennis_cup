import 'dart:async';

import 'package:flutter/material.dart';

enum TimeoutType { medical, techPause, general }

class TimeoutOverlay extends StatefulWidget {
  final TimeoutType type;

  const TimeoutOverlay({super.key, required this.type});

  static Future<void> show(BuildContext context, TimeoutType type) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      pageBuilder: (ctx, _, __) => TimeoutOverlay(type: type),
    );
  }

  @override
  State<TimeoutOverlay> createState() => _TimeoutOverlayState();
}

class _TimeoutOverlayState extends State<TimeoutOverlay> {
  late Duration _duration;
  bool _countDown = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    switch (widget.type) {
      case TimeoutType.medical:
        _duration = const Duration(minutes: 10);
        _countDown = true;
      case TimeoutType.techPause:
        _duration = Duration.zero;
        _countDown = false;
      case TimeoutType.general:
        _duration = const Duration(minutes: 1);
        _countDown = true;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countDown && _duration.inSeconds <= 1) {
        _timer?.cancel();
        if (mounted) Navigator.of(context).pop();
        return;
      }
      setState(() {
        if (_countDown) {
          _duration -= const Duration(seconds: 1);
        } else {
          _duration += const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color get _bgColor => switch (widget.type) {
        TimeoutType.medical => const Color(0xFFC62828),
        TimeoutType.techPause => const Color(0xFF1565C0),
        TimeoutType.general => const Color(0xFFF57F17),
      };

  IconData get _icon => switch (widget.type) {
        TimeoutType.medical => Icons.medical_services,
        TimeoutType.techPause => Icons.pause_circle,
        TimeoutType.general => Icons.timer,
      };

  String get _label => switch (widget.type) {
        TimeoutType.medical => 'Medical Timeout',
        TimeoutType.techPause => 'Technical Pause',
        TimeoutType.general => 'Timeout',
      };

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: 80, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                _label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Tap anywhere to dismiss',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
