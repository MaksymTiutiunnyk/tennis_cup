import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';

class SexFilterCubit extends Cubit<Sex> {
  SexFilterCubit() : super(Sex.All);

  void selectedSex(Sex sex) {
    emit(sex);
  }
}