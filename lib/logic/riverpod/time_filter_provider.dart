import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/data/models/tournament.dart';

class TimeFilterNotifier extends StateNotifier<Time> {
  TimeFilterNotifier() : super(Time.Evening);

  void selectTime(Time time) {
    state = time;
  }
}

final timeFilterProvider = StateNotifierProvider<TimeFilterNotifier, Time>(
    (ref) => TimeFilterNotifier());
