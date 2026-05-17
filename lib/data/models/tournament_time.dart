import 'package:tennis_cup/core/utils/enum_utils.dart';

// ignore: constant_identifier_names
enum Time { Morning, Evening, Day, Midnight, Night }

Time timeFromString(String? value) =>
    enumFromString(Time.values, value, Time.Morning);
