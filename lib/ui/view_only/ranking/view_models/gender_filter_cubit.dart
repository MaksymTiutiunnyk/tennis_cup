import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/gender.dart';

class GenderFilterCubit extends Cubit<Gender?> {
  GenderFilterCubit() : super(null);

  void selectGender(Gender? gender) {
    emit(gender);
  }
}
