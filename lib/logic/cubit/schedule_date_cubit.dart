import 'package:flutter_bloc/flutter_bloc.dart';

class ScheduleDateCubit extends Cubit<DateTime> {
  ScheduleDateCubit() : super(DateTime.now());

  void selectDate(DateTime date) {
    emit(date);
  }
}
