import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/player.dart';

class SelectedPlayer {
  final int id;
  final String name;
  final String? status;

  const SelectedPlayer({required this.id, required this.name, this.status});
}

class PlayerPicker extends StatefulWidget {
  final List<SelectedPlayer> initialPlayers;
  final ValueChanged<List<SelectedPlayer>> onChanged;
  final String? gender;

  /// When set, search is disabled once accepted players reach this count.
  final int? requiredPlayersCount;

  const PlayerPicker({
    super.key,
    this.initialPlayers = const [],
    required this.onChanged,
    this.gender,
    this.requiredPlayersCount,
  });

  @override
  State<PlayerPicker> createState() => _PlayerPickerState();
}

class _PlayerPickerState extends State<PlayerPicker> {
  final _ctrl = TextEditingController();
  late List<SelectedPlayer> _selected;
  List<Player> _results = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.initialPlayers);
  }

  @override
  void didUpdateWidget(PlayerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPlayers != widget.initialPlayers) {
      // Sync updated names/statuses for IDs already in _selected.
      // Preserve items the user added during this session (not in initialPlayers).
      _selected = _selected.map((s) {
        final updated =
            widget.initialPlayers.where((p) => p.id == s.id).firstOrNull;
        return updated ?? s;
      }).toList();
    }
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
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => _loading = true);
      try {
        final players =
            await ServiceLocator.playerRepository.fetchPlayersBySubstring(
          query: query.trim(),
          gender: widget.gender,
        );
        if (mounted) {
          setState(() => _results = players
              .where((p) => !_selected.any((s) => s.id == p.userId))
              .toList());
        }
      } catch (_) {
        if (mounted) setState(() => _results = []);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  void _add(Player player) {
    final id = player.userId;
    if (_selected.any((s) => s.id == id)) return;
    setState(() {
      _selected.add(SelectedPlayer(id: id, name: player.fullName));
      _results = [];
      _ctrl.clear();
    });
    widget.onChanged(List.of(_selected));
  }

  void _remove(SelectedPlayer entry) {
    setState(() => _selected.removeWhere((s) => s.id == entry.id));
    widget.onChanged(List.of(_selected));
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

  bool get _searchDisabled {
    final required = widget.requiredPlayersCount;
    if (required == null) return false;
    final acceptedCount =
        _selected.where((p) => p.status?.toUpperCase() == 'ACCEPTED').length;
    return acceptedCount >= required;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final searchDisabled = _searchDisabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selected.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _selected
                .map((p) => Chip(
                      label: Text(
                        p.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _chipColor(context, p.status),
                      onDeleted: () => _remove(p),
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
            hintText:
                searchDisabled ? 'Player slots are full' : 'Search by name…',
            suffixIcon: _loading
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
        if (_results.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(top: 2),
            elevation: 4,
            child: Column(
              children: _results
                  .map((p) => ListTile(
                        dense: true,
                        title: Text(p.fullName),
                        trailing: Icon(Icons.add_circle_outline,
                            color: colorScheme.primary),
                        onTap: () => _add(p),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
