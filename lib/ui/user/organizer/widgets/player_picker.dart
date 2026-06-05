import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/player_search_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/participant_status_chip.dart';

export 'package:tennis_cup/ui/user/organizer/view_models/player_search_cubit.dart'
    show SelectedPlayer;

class PlayerPicker extends StatefulWidget {
  final String? gender;
  final int? requiredPlayersCount;
  final bool readOnly;

  const PlayerPicker({
    super.key,
    this.gender,
    this.requiredPlayersCount,
    this.readOnly = false,
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
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
                    .map((p) => ParticipantStatusChip(
                          label: p.name,
                          status: p.status,
                          onDeleted: widget.readOnly
                              ? null
                              : () => _cubit.removePlayer(p.id),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],
            if (!widget.readOnly)
              TextField(
                controller: _ctrl,
                enabled: !searchDisabled,
                decoration: InputDecoration(
                  labelText: s.addPlayers,
                  hintText:
                      searchDisabled ? s.playerSlotsFull : s.searchByNameHint,
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
            if (!widget.readOnly && state.searchResults.isNotEmpty)
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
