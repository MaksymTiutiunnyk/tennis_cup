import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/logic/cubit/news_period_cubit.dart';

DateFormat formatter = DateFormat('MMMM yyyy');

class PeriodSection extends StatelessWidget {
  const PeriodSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 2),
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(width: 0.1),
        ),
      ),
      child: BlocBuilder<NewsPeriodCubit, DateTime>(
        builder: (context, state) {
          String formattedPeriod = formatter.format(state);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: state.year == 2018 && state.month == 1
                    ? null
                    : () {
                        context.read<NewsPeriodCubit>().selectPeriod(
                            DateTime(state.year, state.month - 1, state.day));
                      },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              Text(formattedPeriod),
              IconButton(
                onPressed: state.year == DateTime.now().year &&
                        state.month == DateTime.now().month
                    ? null
                    : () {
                        context.read<NewsPeriodCubit>().selectPeriod(
                            DateTime(state.year, state.month + 1, state.day));
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
