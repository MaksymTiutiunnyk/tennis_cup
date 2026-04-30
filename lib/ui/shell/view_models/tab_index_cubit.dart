import 'package:flutter_bloc/flutter_bloc.dart';

class TabIndexCubit extends Cubit<int> {
  TabIndexCubit(super.initialIndex);

  void selectTab(int index) {
    emit(index);
  }
}
