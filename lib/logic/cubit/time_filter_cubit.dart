import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/tournament.dart';

class TimeFilterCubit extends Cubit<Time> {
  TimeFilterCubit(super.initialTime);

  void selectTime(Time time) {
    emit(time);
  }
}
