import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef UserRegistrationSubmitCallback = void Function({
  required String role,
  required String login,
  required String password,
  required String firstName,
  required String lastName,
  String? patronymicName,
  required String birthDate,
  required String gender,
  required String country,
  required String city,
});

class UserRegistrationFormBody extends StatefulWidget {
  final List<String> availableRoles;
  final bool isLoading;
  final UserRegistrationSubmitCallback onSubmit;
  final String submitLabel;
  final Widget? footer;

  const UserRegistrationFormBody({
    super.key,
    required this.availableRoles,
    required this.isLoading,
    required this.onSubmit,
    this.submitLabel = 'Create',
    this.footer,
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
  late String _role;
  DateTime? _birthDate;
  String? _gender;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _role = widget.availableRoles.first;
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      role: _role,
      login: _loginCtrl.text.trim(),
      password: _passwordCtrl.text,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      patronymicName: _patronymicCtrl.text.trim().isEmpty
          ? null
          : _patronymicCtrl.text.trim(),
      birthDate: _birthCtrl.text,
      gender: _gender!,
      country: _countryCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.availableRoles.length > 1) ...[
            SegmentedButton<String>(
              segments: widget.availableRoles
                  .map((r) => ButtonSegment(
                        value: r,
                        label: Text(r[0] + r.substring(1).toLowerCase()),
                      ))
                  .toList(),
              selected: {_role},
              onSelectionChanged: (s) => setState(() => _role = s.first),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _loginCtrl,
            decoration: const InputDecoration(labelText: 'Login *'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password *',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) =>
                (v == null || v.length < 8) ? 'At least 8 characters' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _firstNameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'First name *'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _lastNameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Last name *'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _patronymicCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Patronymic (optional)'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _birthCtrl,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Birth date *',
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today, size: 18),
                onPressed: _pickDate,
              ),
            ),
            onTap: _pickDate,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(labelText: 'Gender *'),
            items: const [
              DropdownMenuItem(value: 'MALE', child: Text('Male')),
              DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
            ],
            onChanged: (v) => setState(() => _gender = v),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _countryCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Country *'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cityCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'City *'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 32),
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
