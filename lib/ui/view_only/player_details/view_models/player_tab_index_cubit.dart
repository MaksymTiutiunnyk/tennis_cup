import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerTabIndexCubit extends Cubit<int> {
  PlayerTabIndexCubit() : super(0);

  void selectTab(int index) => emit(index);
}
