import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleDateNotifier extends StateNotifier<DateTime> {
  // ScheduleDateNotifier()
  //     : super(DateTime(
  //         DateTime.now().year,
  //         DateTime.now().month,
  //         DateTime.now().day,
  //       ));
  ScheduleDateNotifier()
      : super(DateTime(
          2024,
          10,
          30,
        ));

  void selectDate(DateTime date) {
    state = date;
  }
}

final scheduleDateProvider =
    StateNotifierProvider<ScheduleDateNotifier, DateTime>(
        (ref) => ScheduleDateNotifier());
