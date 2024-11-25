import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tennis_cup/providers/schedule_date_provider.dart';

class ScheduleDatePicker extends ConsumerWidget {
  const ScheduleDatePicker({super.key});

  void _pickDate(BuildContext context, WidgetRef ref) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018, 1, 1),
      lastDate: DateTime(2026, 1, 1),
    );

    if (pickedDate == null) {
      return;
    }

    ref.read(scheduleDateProvider.notifier).selectDate(pickedDate);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime selectedDate = ref.watch(scheduleDateProvider);

    return IconButton(
      onPressed: () {
        _pickDate(context, ref);
      },
      icon: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.calendar_today),
          Positioned(
            top: 6,
            child: Text(
              '${selectedDate.day}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
