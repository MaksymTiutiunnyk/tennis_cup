import 'package:flutter_bloc/flutter_bloc.dart';

// TODO: move all logic to NewsCubit
class NewsPeriodCubit extends Cubit<DateTime> {
  NewsPeriodCubit() : super(DateTime.now());

  void selectPeriod(DateTime dateTime) {
    emit(dateTime);
  }
}
