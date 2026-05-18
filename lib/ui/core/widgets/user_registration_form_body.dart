import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/generated/l10n.dart';

typedef UserRegistrationSubmitCallback = void Function({
  String? role,
  String? login,
  String? password,
  required String firstName,
  required String lastName,
  String? patronymicName,
  required String birthDate,
  required String gender,
  required String country,
  required String city,
  String? status,
});

class UserProfileInitialValues {
  final String firstName;
  final String lastName;
  final String? patronymicName;
  final String? birthDate;
  final String? gender;
  final String? country;
  final String? city;

  const UserProfileInitialValues({
    required this.firstName,
    required this.lastName,
    this.patronymicName,
    this.birthDate,
    this.gender,
    this.country,
    this.city,
  });
}

class UserRegistrationFormBody extends StatefulWidget {
  final List<String> availableRoles;
  final bool isLoading;
  final UserRegistrationSubmitCallback onSubmit;
  final String submitLabel;
  final Widget? footer;
  final UserProfileInitialValues? initialValues;
  /// When non-null, shows a block/unblock button above Save.
  /// Pass the user's current status string (e.g. 'ACTIVE', 'BLOCKED').
  final String? currentStatus;

  const UserRegistrationFormBody({
    super.key,
    this.availableRoles = const [],
    required this.isLoading,
    required this.onSubmit,
    this.submitLabel = 'Create',
    this.footer,
    this.initialValues,
    this.currentStatus,
  });

  @override
  State<UserRegistrationFormBody> createState() =>
      _UserRegistrationFormBodyState();
}

class _UserRegistrationFormBodyState extends State<UserRegistrationFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _patronymicCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  String _role = '';
  DateTime? _birthDate;
  String? _gender;
  bool _obscure = true;

  bool get _isEditMode => widget.initialValues != null;

  String _roleLabel(String role, S s) => switch (role.toUpperCase()) {
        'PLAYER' => s.rolePlayer,
        'REFEREE' => s.roleReferee,
        'ORGANIZER' => s.roleOrganizer,
        'ADMIN' => s.roleAdmin,
        _ => role[0] + role.substring(1).toLowerCase(),
      };

  @override
  void initState() {
    super.initState();
    if (!_isEditMode && widget.availableRoles.isNotEmpty) {
      _role = widget.availableRoles.first;
    }
    final v = widget.initialValues;
    if (v != null) {
      _firstNameCtrl.text = v.firstName;
      _lastNameCtrl.text = v.lastName;
      _patronymicCtrl.text = v.patronymicName ?? '';
      _countryCtrl.text = v.country ?? '';
      _cityCtrl.text = v.city ?? '';
      if (v.birthDate != null && v.birthDate!.isNotEmpty) {
        _birthCtrl.text = v.birthDate!;
        _birthDate = DateTime.tryParse(v.birthDate!);
      }
      if (v.gender != null && v.gender!.isNotEmpty) {
        _gender = v.gender;
      }
    }
  }

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _patronymicCtrl.dispose();
    _birthCtrl.dispose();
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1930),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submit({String? status}) {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      role: _isEditMode ? null : _role,
      login: _isEditMode ? null : _loginCtrl.text.trim(),
      password: _isEditMode ? null : _passwordCtrl.text,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      patronymicName: _patronymicCtrl.text.trim().isEmpty
          ? null
          : _patronymicCtrl.text.trim(),
      birthDate: _birthCtrl.text,
      gender: _gender!,
      country: _countryCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      status: status,
    );
  }

  Future<void> _onBlockPressed() async {
    final s = S.of(context);
    final isBlocked = widget.currentStatus == 'BLOCKED';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBlocked ? s.unblockUser : s.blockUser),
        content: Text(
          isBlocked ? s.unblockUserContent : s.blockUserContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: isBlocked
                ? null
                : FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
            child: Text(isBlocked ? s.unblockButton : s.blockButton),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _submit(status: isBlocked ? 'ACTIVE' : 'BLOCKED');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isEditMode && widget.availableRoles.length > 1) ...[
            SegmentedButton<String>(
              style: SegmentedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                textStyle: const TextStyle(fontSize: 12),
              ).copyWith(
                minimumSize: const WidgetStatePropertyAll(Size.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: widget.availableRoles
                  .map((r) => ButtonSegment(
                        value: r,
                        label: Text(
                          _roleLabel(r, s),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              selected: {_role},
              onSelectionChanged: (sel) => setState(() => _role = sel.first),
            ),
            const SizedBox(height: 16),
          ],
          if (!_isEditMode) ...[
            TextFormField(
              controller: _loginCtrl,
              decoration: InputDecoration(labelText: '${s.loginField} *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? s.required : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: '${s.passwordField} *',
                suffixIcon: IconButton(
                  icon:
                      Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) =>
                  (v == null || v.length < 8) ? s.atLeast8Chars : null,
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _firstNameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: '${s.firstNameField} *'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? s.required : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _lastNameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: '${s.lastNameField} *'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? s.required : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _patronymicCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: s.patronymicField),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _birthCtrl,
            readOnly: true,
            decoration: InputDecoration(
              labelText: '${s.birthDateField} *',
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today, size: 18),
                onPressed: _pickDate,
              ),
            ),
            onTap: _pickDate,
            validator: (v) => (v == null || v.isEmpty) ? s.required : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: InputDecoration(labelText: '${s.genderField} *'),
            items: [
              DropdownMenuItem(value: 'MALE', child: Text(s.male)),
              DropdownMenuItem(value: 'FEMALE', child: Text(s.female)),
            ],
            onChanged: (v) => setState(() => _gender = v),
            validator: (v) => v == null ? s.required : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _countryCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: '${s.countryField} *'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? s.required : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cityCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: '${s.cityField} *'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? s.required : null,
          ),
          const SizedBox(height: 32),
          if (widget.currentStatus != null) ...[
            OutlinedButton(
              onPressed: widget.isLoading ? null : _onBlockPressed,
              style: widget.currentStatus == 'BLOCKED'
                  ? null
                  : OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                    ),
              child: Text(
                widget.currentStatus == 'BLOCKED'
                    ? s.unblockUserButton
                    : s.blockUserButton,
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.submitLabel),
            ),
          ),
          if (widget.footer != null) ...[
            const SizedBox(height: 16),
            widget.footer!,
          ],
        ],
      ),
    );
  }
}
