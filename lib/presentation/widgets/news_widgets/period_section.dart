import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/logic/riverpod/news_period_provider.dart';

DateFormat formatter = DateFormat('MMMM yyyy');

class PeriodSection extends ConsumerWidget {
  const PeriodSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime period = ref.watch(newsPeriodProvider);
    String formattedPeriod = formatter.format(period);

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
                : () {
                    ref.read(newsPeriodProvider.notifier).selectPeriod(
                        DateTime(period.year, period.month - 1, period.day));
                  },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          Text(formattedPeriod),
          IconButton(
            onPressed: period.year == DateTime.now().year &&
                    period.month == DateTime.now().month
                ? null
                : () {
                    ref.read(newsPeriodProvider.notifier).selectPeriod(
                        DateTime(period.year, period.month + 1, period.day));
                  },
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }
}
