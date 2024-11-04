import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';

class RankingFilters extends StatefulWidget {
  const RankingFilters({super.key});

  @override
  State<RankingFilters> createState() {
    return _RankingFiltersState();
  }
}

class _RankingFiltersState extends State<RankingFilters> {
  Sex? _sex = Sex.All;

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
            child: ListView(
              children: [
                for (Sex sex in Sex.values)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(sex.name),
                      Radio<Sex>(
                        value: sex,
                        groupValue: _sex,
                        onChanged: (value) {
                          setState(() {
                            _sex = value;
                          });
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
