import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/data/repositories/news_repository.dart';

part 'organizer_news_state.dart';

class OrganizerNewsCubit extends Cubit<OrganizerNewsState> {
  final NewsRepository _repository;

  OrganizerNewsCubit({required NewsRepository repository})
      : _repository = repository,
        super(OrgNewsLoading(DateTime.now())) {
    load(DateTime.now());
  }

  Future<void> load(DateTime period) async {
    emit(OrgNewsLoading(period));
    try {
      final items = await _repository.fetchNewsWithinPeriod(
        DateTime(period.year, period.month),
        DateTime(period.year, period.month + 1),
      );
      emit(OrgNewsLoaded(period, items));
    } catch (e) {
      emit(OrgNewsError(period, _message(e)));
    }
  }

  Future<void> create({
    required String title,
    required String body,
    required DateTime newsTimestamp,
    required String importance,
    File? image,
  }) async {
    try {
      await _repository.createNews(
        title: title,
        body: body,
        newsTimestamp: newsTimestamp,
        importance: importance,
        image: image,
      );
      await load(state.period);
    } catch (e) {
      emit(OrgNewsError(state.period, _message(e)));
    }
  }

  Future<void> update(
    int id, {
    String? title,
    String? body,
    DateTime? newsTimestamp,
    String? importance,
    bool removeImage = false,
    File? image,
  }) async {
    try {
      await _repository.updateNews(
        id,
        title: title,
        body: body,
        newsTimestamp: newsTimestamp,
        importance: importance,
        removeImage: removeImage,
        image: image,
      );
      await load(state.period);
    } catch (e) {
      emit(OrgNewsError(state.period, _message(e)));
    }
  }

  Future<void> delete(int id) async {
    final current = state;
    if (current is OrgNewsLoaded) {
      emit(OrgNewsLoaded(
        current.period,
        current.items.where((n) => n.id != id).toList(),
      ));
    }
    try {
      await _repository.deleteNews(id);
    } catch (e) {
      if (current is OrgNewsLoaded) emit(current);
      emit(OrgNewsError(state.period, _message(e)));
    }
  }

  static String _message(Object e) =>
      e is Exception ? e.toString().replaceFirst('Exception: ', '') : '$e';
}
