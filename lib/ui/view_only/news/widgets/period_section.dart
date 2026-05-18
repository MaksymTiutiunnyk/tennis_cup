import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/ui/view_only/news/view_models/news_cubit.dart';

class PeriodSection extends StatelessWidget {
  const PeriodSection({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 2),
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(width: 0.1),
        ),
      ),
      child: BlocBuilder<NewsCubit, NewsState>(
        builder: (context, state) {
          final period = state.selectedPeriod;
          final formattedPeriod =
              DateFormat('LLLL yyyy', locale).format(period);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: period.year == 2018 && period.month == 1
                    ? null
                    : () {
                        context.read<NewsCubit>().selectPeriod(
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
                        context.read<NewsCubit>().selectPeriod(
                            DateTime(period.year, period.month + 1, period.day));
                      },
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          );
        },
      ),
    );
  }
}
