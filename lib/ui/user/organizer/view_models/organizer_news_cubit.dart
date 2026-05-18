import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
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
      if (isClosed) return;
      emit(OrgNewsLoaded(period, items));
    } catch (e) {
      if (isClosed) return;
      emit(OrgNewsError(period, errorMessage(e)));
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
      if (isClosed) return;
      emit(OrgNewsError(state.period, errorMessage(e)));
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
      if (isClosed) return;
      emit(OrgNewsError(state.period, errorMessage(e)));
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
      if (isClosed) return;
      if (current is OrgNewsLoaded) emit(current);
      emit(OrgNewsError(state.period, errorMessage(e)));
    }
  }

}
