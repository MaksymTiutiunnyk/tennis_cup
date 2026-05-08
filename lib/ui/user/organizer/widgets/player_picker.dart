import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/player.dart';

class SelectedPlayer {
  final int id;
  final String name;

  const SelectedPlayer({required this.id, required this.name});
}

class PlayerPicker extends StatefulWidget {
  final List<SelectedPlayer> initialPlayers;
  final ValueChanged<List<SelectedPlayer>> onChanged;

  const PlayerPicker({
    super.key,
    this.initialPlayers = const [],
    required this.onChanged,
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selected.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _selected
                .map((p) => Chip(
                      label: Text(p.name),
                      onDeleted: () => _remove(p),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: _ctrl,
          decoration: InputDecoration(
            labelText: 'Add players',
            hintText: 'Search by name…',
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
