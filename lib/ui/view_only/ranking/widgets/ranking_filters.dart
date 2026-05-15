import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/ui/view_only/ranking/view_models/gender_filter_cubit.dart';

class RankingFilters extends StatelessWidget {
  const RankingFilters({super.key});

  static const _options = <(Gender?, String)>[
    (null, 'All'),
    (Gender.male, 'Male'),
    (Gender.female, 'Female'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: BlocBuilder<GenderFilterCubit, Gender?>(
              builder: (context, state) => ListView(
                children: [
                  for (final (value, label) in _options)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label),
                        Radio<Gender?>(
                          value: value,
                          groupValue: state,
                          onChanged: (v) =>
                              context.read<GenderFilterCubit>().selectGender(v),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
