import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/user_search_result.dart';

class RefereeSearchField extends StatefulWidget {
  final int? initialRefereeId;
  final ValueChanged<UserSearchResult?> onChanged;

  const RefereeSearchField({
    super.key,
    this.initialRefereeId,
    required this.onChanged,
  });

  @override
  State<RefereeSearchField> createState() => _RefereeSearchFieldState();
}

class _RefereeSearchFieldState extends State<RefereeSearchField> {
  final _ctrl = TextEditingController();
  UserSearchResult? _selected;
  List<UserSearchResult> _results = [];
  bool _loading = false;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final id = widget.initialRefereeId;
    if (id != null) {
      _loading = true;
      ServiceLocator.adminRepository.getUserById(id).then((profile) {
        if (mounted) {
          setState(() {
            _selected = UserSearchResult(
              userId: profile.userId,
              firstName: profile.firstName,
              lastName: profile.lastName,
              roles: profile.roles,
              avatarUrl: profile.avatarUrl,
            );
            _loading = false;
          });
        }
      }).catchError((_) {
        if (mounted) {
          setState(() {
            _selected = UserSearchResult(userId: id, firstName: 'Referee', lastName: '#$id');
            _loading = false;
          });
        }
      });
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
      setState(() {
        _loading = true;
        _error = null;
      });
      try {
        final results =
            await ServiceLocator.adminRepository.searchReferees(query.trim());
        if (mounted) setState(() => _results = results);
      } catch (e) {
        if (mounted) {
          setState(() {
            _results = [];
            _error = e.toString();
          });
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  void _select(UserSearchResult result) {
    setState(() {
      _selected = result;
      _results = [];
      _ctrl.clear();
    });
    widget.onChanged(result);
  }

  void _clear() {
    setState(() {
      _selected = null;
      _results = [];
      _ctrl.clear();
    });
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    if (_selected != null) {
      return InputDecorator(
        decoration: const InputDecoration(labelText: 'Referee'),
        child: Row(
          children: [
            const Icon(Icons.person, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_selected!.fullName} (ID: ${_selected!.userId})',
              ),
            ),
            InkWell(
              onTap: _clear,
              child: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _ctrl,
          decoration: InputDecoration(
            labelText: 'Referee',
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
                : const Icon(Icons.search),
          ),
          onChanged: _onChanged,
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
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
                        onTap: () => _select(r),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
