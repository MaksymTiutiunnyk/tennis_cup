import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class LanguageCubit extends HydratedCubit<Locale> {
  LanguageCubit() : super(const Locale('en'));

  void setLocale(Locale locale) => emit(locale);

  @override
  Locale fromJson(Map<String, dynamic> json) =>
      Locale(json['languageCode'] as String);

  @override
  Map<String, dynamic> toJson(Locale state) =>
      {'languageCode': state.languageCode};
}
