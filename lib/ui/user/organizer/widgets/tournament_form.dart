import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/models/tournament_request.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/organizer_tournaments_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/player_picker.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/referee_picker.dart';

final _displayFmt = DateFormat('dd MMM yyyy HH:mm');

class TournamentForm extends StatefulWidget {
  final Tournament? existing;

  const TournamentForm({super.key, this.existing});

  @override
  State<TournamentForm> createState() => _TournamentFormState();
}

class _TournamentFormState extends State<TournamentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _requiredPlayersCtrl;
  late final TextEditingController _setsToWinCtrl;

  String _type = 'MORNING';
  String _gender = 'MALE';
  DateTime _startTime = DateTime.now().add(const Duration(days: 1));
  int? _arenaId;
  List<Arena> _arenas = [];
  bool _loadingArenas = true;

  List<SelectedReferee> _selectedReferees = [];
  List<SelectedPlayer> _selectedPlayers = [];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _durationCtrl = TextEditingController(text: '30');
    _requiredPlayersCtrl = TextEditingController(text: '8');
    _setsToWinCtrl = TextEditingController(text: '2');
    if (e != null) {
      _type = e.time.name.toUpperCase();
      if (e.gender.isNotEmpty) _gender = e.gender;
      _arenaId = int.tryParse(e.arena.id);
      _startTime = e.date;

      // Populate referee invitations (exclude DECLINED/CANCELLED)
      _selectedReferees = e.refereeInvitations
          .map((r) => SelectedReferee(
                id: r.refereeId,
                name: 'Referee #${r.refereeId}',
                status: r.status,
              ))
          .toList();
      _resolveRefereeNames();

      // Populate player invitations (exclude CANCELLED)
      _selectedPlayers = e.participantInvitations
          .map((p) => SelectedPlayer(
                id: p.playerId,
                name: 'Player #${p.playerId}',
                status: p.status,
              ))
          .toList();
      _resolvePlayerNames();
    }
    _loadArenas();
  }

  Future<void> _resolveRefereeNames() async {
    final resolved = await Future.wait(
      _selectedReferees.map((r) async {
        try {
          final profile =
              await ServiceLocator.adminRepository.getUserById(r.id);
          return SelectedReferee(
            id: r.id,
            name: '${profile.firstName} ${profile.lastName}',
            status: r.status,
          );
        } catch (_) {
          return r;
        }
      }),
    );
    if (mounted) setState(() => _selectedReferees = resolved);
  }

  Future<void> _resolvePlayerNames() async {
    final resolved = await Future.wait(
      _selectedPlayers.map((p) async {
        try {
          final player =
              await ServiceLocator.playerRepository.fetchPlayerById(p.id);
          return SelectedPlayer(
            id: p.id,
            name: player.fullName,
            status: p.status,
          );
        } catch (_) {
          return p;
        }
      }),
    );
    if (mounted) setState(() => _selectedPlayers = resolved);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _durationCtrl.dispose();
    _requiredPlayersCtrl.dispose();
    _setsToWinCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadArenas() async {
    try {
      final arenas = await ServiceLocator.arenaRepository.fetchAllArenas();
      if (mounted) {
        setState(() {
          _arenas = arenas;
          _arenaId ??= arenas.isNotEmpty ? int.tryParse(arenas.first.id) : null;
          _loadingArenas = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingArenas = false);
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );
    if (time == null) return;
    setState(() {
      _startTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEdit && _selectedReferees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one referee')),
      );
      return;
    }

    final cubit = context.read<OrganizerTournamentsCubit>();
    final playerIds = _selectedPlayers.isEmpty
        ? null
        : _selectedPlayers.map((p) => p.id).toList();
    final refereeIds = _selectedReferees.map((r) => r.id).toList();

    if (_isEdit) {
      await cubit.update(
        int.parse(widget.existing!.tournamentId),
        UpdateTournamentRequest(
          name: _nameCtrl.text.trim(),
          type: _type,
          gender: _gender,
          startTime: _startTime,
          arenaId: _arenaId,
          refereeIds: refereeIds,
          playerIds: playerIds,
        ),
      );
    } else {
      await cubit.create(CreateTournamentRequest(
        name: _nameCtrl.text.trim(),
        type: _type,
        gender: _gender,
        startTime: _startTime,
        arenaId: _arenaId ?? 0,
        refereeIds: refereeIds,
        matchDurationMinutes: int.tryParse(_durationCtrl.text.trim()) ?? 30,
        requiredPlayersCount:
            int.tryParse(_requiredPlayersCtrl.text.trim()) ?? 8,
        setsToWin: int.tryParse(_setsToWinCtrl.text.trim()) ?? 2,
        playerIds: playerIds,
      ));
    }

    if (mounted && cubit.state is! OrgTournamentsError) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Tournament' : 'New Tournament'),
      ),
      body: _loadingArenas
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: const [
                      'MORNING',
                      'DAY',
                      'EVENING',
                      'NIGHT',
                      'MIDNIGHT'
                    ]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: const ['MALE', 'FEMALE']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _gender = v!),
                  ),
                  const SizedBox(height: 12),
                  if (_arenas.isNotEmpty)
                    DropdownButtonFormField<int>(
                      value: _arenaId,
                      decoration: const InputDecoration(labelText: 'Arena'),
                      items: _arenas
                          .map((a) => DropdownMenuItem(
                              value: int.tryParse(a.id),
                              child:
                                  Text('${a.title} (${a.city ?? ''})'.trim())))
                          .toList(),
                      onChanged: (v) => setState(() => _arenaId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    )
                  else
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Arena ID'),
                      keyboardType: TextInputType.number,
                      initialValue: _arenaId?.toString(),
                      onChanged: (v) => _arenaId = int.tryParse(v),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  const SizedBox(height: 12),
                  RefereePicker(
                    initialReferees: _selectedReferees,
                    onChanged: (refs) =>
                        setState(() => _selectedReferees = refs),
                  ),
                  const SizedBox(height: 12),
                  if (!_isEdit) ...[
                    TextFormField(
                      controller: _durationCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Match duration (minutes)'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _requiredPlayersCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Required players count'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 2) return 'Min 2 players';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _setsToWinCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Sets to win'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1 || n > 4) {
                          return 'Must be 1–4';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Start time'),
                    subtitle: Text(_displayFmt.format(_startTime)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDateTime,
                  ),
                  const SizedBox(height: 12),
                  PlayerPicker(
                    initialPlayers: _selectedPlayers,
                    gender: _gender,
                    requiredPlayersCount: widget.existing?.requiredPlayersCount,
                    onChanged: (players) =>
                        setState(() => _selectedPlayers = players),
                  ),
                  const SizedBox(height: 24),
                  BlocConsumer<OrganizerTournamentsCubit,
                      OrganizerTournamentsState>(
                    listener: (context, state) {
                      if (state is OrgTournamentsError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message)),
                        );
                      }
                    },
                    builder: (context, state) => FilledButton(
                      onPressed:
                          state is OrgTournamentsLoading ? null : _submit,
                      child: state is OrgTournamentsLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEdit ? 'Save' : 'Create'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
