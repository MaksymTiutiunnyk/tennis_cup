import 'package:flutter_bloc/flutter_bloc.dart';

class ScheduleDateCubit extends Cubit<DateTime> {
  ScheduleDateCubit(super.initialDate);

  void selectDate(DateTime date) {
    emit(date);
  }
}
