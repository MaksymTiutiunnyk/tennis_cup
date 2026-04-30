import 'package:flutter_bloc/flutter_bloc.dart';

class LiveStreamMatchIndexCubit extends Cubit<int> {
  LiveStreamMatchIndexCubit() : super(0);

  void setIndex(int index) {
    emit(index);
  }
}