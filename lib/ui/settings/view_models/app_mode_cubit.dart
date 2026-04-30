import 'package:flutter_bloc/flutter_bloc.dart';

enum AppMode { viewOnly, playerManager }

class AppModeCubit extends Cubit<AppMode> {
  AppModeCubit() : super(AppMode.viewOnly);

  void switchTo(AppMode mode) => emit(mode);
}
