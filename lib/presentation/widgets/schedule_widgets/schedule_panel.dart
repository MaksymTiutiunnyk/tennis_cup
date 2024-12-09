import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/logic/cubit/arena_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/schedule_date_cubit.dart';
import 'package:tennis_cup/logic/cubit/time_filter_cubit.dart';
import 'package:tennis_cup/presentation/widgets/schedule_widgets/schedule_date_picker.dart';
import 'package:tennis_cup/presentation/widgets/schedule_widgets/schedule_filters.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

class SchedulePanel extends StatelessWidget {
  const SchedulePanel({super.key});

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: BlocProvider.of<TimeFilterCubit>(context),
          ),
          BlocProvider.value(
            value: BlocProvider.of<ArenaFilterCubit>(context),
          ),
        ],
        child: const ScheduleFilters(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onInverseSurface,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlocBuilder<ArenaFilterCubit, Arena>(
            builder: (context, state) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: state.color,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arena: ${state.title}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    BlocBuilder<ScheduleDateCubit, DateTime>(
                      builder: (context, dateState) =>
                          BlocBuilder<TimeFilterCubit, Time>(
                        builder: (context, timeState) => Text(
                          '${formatter.format(dateState)} ${timeState.name}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              const ScheduleDatePicker(),
              IconButton(
                onPressed: () {
                  _showFilters(context);
                },
                icon: const Icon(Icons.filter_list),
              )
            ],
          ),
        ],
      ),
    );
  }
}
