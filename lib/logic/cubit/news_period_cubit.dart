import 'package:flutter_bloc/flutter_bloc.dart';

class NewsPeriodCubit extends Cubit<DateTime> {
  NewsPeriodCubit() : super(DateTime.now());

  void selectPeriod(DateTime dateTime) {
    emit(dateTime);
  }
}
