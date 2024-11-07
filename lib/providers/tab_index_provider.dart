import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabIndexNotifier extends StateNotifier<int> {
  TabIndexNotifier() : super(0);

  void selectTab(int index) {
    state = index;
  }
}

final tabIndexProvider =
    StateNotifierProvider<TabIndexNotifier, int>((ref) => TabIndexNotifier());
