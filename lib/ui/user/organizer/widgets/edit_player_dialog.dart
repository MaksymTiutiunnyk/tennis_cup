import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/combined_user.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/users_search_cubit.dart';

class EditPlayerDialog extends StatefulWidget {
  final CombinedUser user;

  const EditPlayerDialog({super.key, required this.user});

  @override
  State<EditPlayerDialog> createState() => _EditPlayerDialogState();
}

class _EditPlayerDialogState extends State<EditPlayerDialog> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _patronymicCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _cityCtrl;

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  DateTime? _birthDate;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.user.firstName);
    _lastNameCtrl = TextEditingController(text: widget.user.lastName);
    _patronymicCtrl = TextEditingController();
    _countryCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _patronymicCtrl.dispose();
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.user.fullName}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Last name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _patronymicCtrl,
                textCapitalization: TextCapitalization.words,
                decoration:
                    const InputDecoration(labelText: 'Patronymic (optional)'),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _birthDate == null
                      ? 'Birth date (optional)'
                      : '${_birthDate!.year}-'
                          '${_birthDate!.month.toString().padLeft(2, '0')}-'
                          '${_birthDate!.day.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _birthDate == null
                            ? Theme.of(context).hintColor
                            : null,
                      ),
                ),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration:
                    const InputDecoration(labelText: 'Gender (optional)'),
                items: const [
                  DropdownMenuItem(value: 'MALE', child: Text('Male')),
                  DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                ],
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _countryCtrl,
                textCapitalization: TextCapitalization.words,
                decoration:
                    const InputDecoration(labelText: 'Country (optional)'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'City (optional)'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loading ? null : _uploadAvatar,
                icon: const Icon(Icons.photo_camera, size: 18),
                label: const Text('Upload avatar'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _uploadAvatar() async {
    setState(() => _loading = true);
    try {
      await context.read<UsersSearchCubit>().uploadAvatar(widget.user.playerId!);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar upload failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final fields = <String, dynamic>{
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        if (_patronymicCtrl.text.trim().isNotEmpty)
          'patronymicName': _patronymicCtrl.text.trim(),
        if (_birthDate != null) 'birthDate': _isoDate(),
        if (_gender != null) 'gender': _gender,
        if (_countryCtrl.text.trim().isNotEmpty)
          'country': _countryCtrl.text.trim(),
        if (_cityCtrl.text.trim().isNotEmpty) 'city': _cityCtrl.text.trim(),
      };
      await context
          .read<UsersSearchCubit>()
          .updatePlayer(widget.user.playerId!, fields);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update player')),
        );
        setState(() => _loading = false);
      }
    }
  }

  String _isoDate() {
    final d = _birthDate!;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
