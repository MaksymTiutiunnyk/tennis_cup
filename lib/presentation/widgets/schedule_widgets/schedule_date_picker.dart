import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:tennis_cup/logic/cubit/schedule_date_cubit.dart';

class ScheduleDatePicker extends StatelessWidget {
  const ScheduleDatePicker({super.key});

  void _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018, 1, 1),
      lastDate: DateTime(2026, 1, 1),
    );

    if (pickedDate == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    context.read<ScheduleDateCubit>().selectDate(pickedDate);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _pickDate(context);
      },
      icon: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.calendar_today),
          Positioned(
            top: 6,
            child: BlocBuilder<ScheduleDateCubit, DateTime>(
              builder: (context, state) => Text(
                '${state.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
