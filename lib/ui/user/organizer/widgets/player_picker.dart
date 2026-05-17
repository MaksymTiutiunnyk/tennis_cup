import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/player_search_cubit.dart';

export 'package:tennis_cup/ui/user/organizer/view_models/player_search_cubit.dart'
    show SelectedPlayer;

class PlayerPicker extends StatefulWidget {
  final String? gender;
  final int? requiredPlayersCount;

  const PlayerPicker({
    super.key,
    this.gender,
    this.requiredPlayersCount,
  });

  @override
  State<PlayerPicker> createState() => _PlayerPickerState();
}

class _PlayerPickerState extends State<PlayerPicker> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  late final PlayerPickerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PlayerPickerCubit>();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      _cubit.clearSearch();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _cubit.search(query, gender: widget.gender);
    });
  }

  Color? _chipColor(BuildContext context, String? status) {
    return switch (status?.toUpperCase()) {
      'ACCEPTED' => Colors.green[900],
      'PENDING' => Colors.blue[900],
      'DECLINED' => Colors.red[900],
      'CANCELLED' => Colors.grey[700],
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<PlayerPickerCubit, PlayerPickerState>(
      builder: (context, state) {
        final requiredPlayersCount = widget.requiredPlayersCount;
        final searchDisabled = requiredPlayersCount != null &&
            state.selected
                    .where((p) => p.status?.toUpperCase() == 'ACCEPTED')
                    .length >=
                requiredPlayersCount;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.selected.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: state.selected
                    .map((p) => Chip(
                          label: Text(
                            p.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _chipColor(context, p.status),
                          onDeleted: () => _cubit.removePlayer(p.id),
                          deleteIconColor: Colors.white,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: _ctrl,
              enabled: !searchDisabled,
              decoration: InputDecoration(
                labelText: 'Add players',
                hintText: searchDisabled
                    ? 'Player slots are full'
                    : 'Search by name…',
                suffixIcon: state.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.person_search),
              ),
              onChanged: _onChanged,
            ),
            if (state.searchResults.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(top: 2),
                elevation: 4,
                child: Column(
                  children: state.searchResults
                      .map((p) => ListTile(
                            dense: true,
                            title: Text(p.fullName),
                            trailing: Icon(Icons.add_circle_outline,
                                color: colorScheme.primary),
                            onTap: () {
                              _ctrl.clear();
                              _cubit.addPlayer(p);
                            },
                          ))
                      .toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}
