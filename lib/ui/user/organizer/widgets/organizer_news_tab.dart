import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/organizer_news_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/news_form.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/organizer_news_card.dart';

class OrganizerNewsTab extends StatelessWidget {
  const OrganizerNewsTab({super.key});

  void _openForm(BuildContext context, News? existing) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<OrganizerNewsCubit>(),
        child: NewsForm(existing: existing),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrganizerNewsCubit(
        repository: ServiceLocator.newsRepository,
      ),
      child: BlocBuilder<OrganizerNewsCubit, OrganizerNewsState>(
        builder: (context, state) {
          final s = S.of(context);
          return Scaffold(
            body: Column(
              children: [
                _PeriodBar(period: state.period),
                Expanded(
                  child: switch (state) {
                    OrgNewsLoading() =>
                      const Center(child: CircularProgressIndicator()),
                    OrgNewsError(message: final m) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(m, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => context
                                  .read<OrganizerNewsCubit>()
                                  .load(state.period),
                              child: Text(s.retry),
                            ),
                          ],
                        ),
                      ),
                    OrgNewsLoaded(items: final list) when list.isEmpty =>
                      Center(child: Text(s.noNewsThisMonth)),
                    OrgNewsLoaded(items: final list) => RefreshIndicator(
                        onRefresh: () => context
                            .read<OrganizerNewsCubit>()
                            .load(state.period),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: list.length,
                          itemBuilder: (_, i) => OrganizerNewsCard(
                            news: list[i],
                            onEdit: () => _openForm(context, list[i]),
                          ),
                        ),
                      ),
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'organizer_news_fab',
              onPressed: () => _openForm(context, null),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}

class _PeriodBar extends StatelessWidget {
  final DateTime period;
  const _PeriodBar({required this.period});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).languageCode;
    final formattedPeriod = DateFormat('LLLL yyyy', locale).format(period);
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 2),
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(width: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: period.year == 2018 && period.month == 1
                ? null
                : () => context
                    .read<OrganizerNewsCubit>()
                    .load(DateTime(period.year, period.month - 1)),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          Text(formattedPeriod),
          IconButton(
            onPressed: period.year == now.year && period.month == now.month
                ? null
                : () => context
                    .read<OrganizerNewsCubit>()
                    .load(DateTime(period.year, period.month + 1)),
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }
}
