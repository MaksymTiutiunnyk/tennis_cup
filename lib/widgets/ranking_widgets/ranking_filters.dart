import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/providers/ranking_filters_provider.dart';

class RankingFilters extends ConsumerStatefulWidget {
  const RankingFilters({super.key});

  @override
  ConsumerState<RankingFilters> createState() {
    return _RankingFiltersState();
  }
}

class _RankingFiltersState extends ConsumerState<RankingFilters> {
  @override
  Widget build(BuildContext context) {
    Sex selectedSex = ref.watch(rankingFiltersProvider);

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
            child: ListView(
              children: [
                for (Sex sex in Sex.values)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(sex.name),
                      Radio<Sex>(
                        value: sex,
                        groupValue: selectedSex,
                        onChanged: (value) {
                          ref
                              .read(rankingFiltersProvider.notifier)
                              .selectSex(value!);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
