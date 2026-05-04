part of 'organizer_news_cubit.dart';

sealed class OrganizerNewsState {
  final DateTime period;
  const OrganizerNewsState(this.period);
}

class OrgNewsLoading extends OrganizerNewsState {
  const OrgNewsLoading(super.period);
}

class OrgNewsLoaded extends OrganizerNewsState {
  final List<News> items;
  OrgNewsLoaded(super.period, this.items);
}

class OrgNewsError extends OrganizerNewsState {
  final String message;
  OrgNewsError(super.period, this.message);
}
