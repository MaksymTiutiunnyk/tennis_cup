import 'package:equatable/equatable.dart';
import 'package:tennis_cup/data/models/user.dart';

class ScheduledMatchPreview extends Equatable {
  final int id;
  final DateTime scheduledStart;
  final User? bluePlayer;
  final User? redPlayer;

  const ScheduledMatchPreview({
    required this.id,
    required this.scheduledStart,
    required this.bluePlayer,
    required this.redPlayer,
  });

  @override
  List<Object?> get props => [id, scheduledStart, bluePlayer, redPlayer];
}
