import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/user_search_result.dart';

class SelectedReferee {
  final int id;
  final String name;
  // null = newly added candidate, 'ACCEPTED'/'PENDING' = existing invitation
  final String? status;

  const SelectedReferee({required this.id, required this.name, this.status});
}

class RefereePicker extends StatefulWidget {
  final List<SelectedReferee> initialReferees;
  final ValueChanged<List<SelectedReferee>> onChanged;

  const RefereePicker({
    super.key,
    this.initialReferees = const [],
    required this.onChanged,
  });

  @override
  State<RefereePicker> createState() => _RefereePickerState();
}

class _RefereePickerState extends State<RefereePicker> {
  final _ctrl = TextEditingController();
  late List<SelectedReferee> _selected;
  List<UserSearchResult> _results = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.initialReferees);
  }

  @override
  void didUpdateWidget(RefereePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialReferees != widget.initialReferees) {
      _selected = _selected.map((s) {
        final updated = widget.initialReferees
            .where((r) => r.id == s.id)
            .firstOrNull;
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
        final results =
            await ServiceLocator.adminRepository.searchReferees(query.trim());
        if (mounted) {
          setState(() => _results = results
              .where((r) => !_selected.any((s) => s.id == r.userId))
              .toList());
        }
      } catch (_) {
        if (mounted) setState(() => _results = []);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  void _add(UserSearchResult result) {
    if (_selected.any((s) => s.id == result.userId)) return;
    setState(() {
      _selected.add(SelectedReferee(id: result.userId, name: result.fullName));
      _results = [];
      _ctrl.clear();
    });
    widget.onChanged(List.of(_selected));
  }

  void _remove(SelectedReferee entry) {
    setState(() => _selected.removeWhere((s) => s.id == entry.id));
    widget.onChanged(List.of(_selected));
  }

  Color? _chipColor(BuildContext context, String? status) {
    return switch (status?.toUpperCase()) {
      'ACCEPTED' => Colors.green[900],
      'PENDING' => Colors.blue[900],
      _ => null,
    };
  }

  bool get _hasAccepted =>
      _selected.any((r) => r.status?.toUpperCase() == 'ACCEPTED');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final searchDisabled = _hasAccepted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selected.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _selected
                .map((r) => Chip(
                      label: Text(r.name,
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: _chipColor(context, r.status),
                      onDeleted: () => _remove(r),
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
            labelText: 'Add referee',
            hintText: searchDisabled ? 'Referee already accepted' : 'Search by name…',
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
                  .map((r) => ListTile(
                        dense: true,
                        title: Text(r.fullName),
                        subtitle: Text('ID: ${r.userId}'),
                        trailing: Icon(Icons.add_circle_outline,
                            color: colorScheme.primary),
                        onTap: () => _add(r),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
