import 'package:tennis_cup/core/utils/enum_utils.dart';

enum Gender { male, female }

Gender? genderFromString(String? value) =>
    enumFromStringOrNull(Gender.values, value);
