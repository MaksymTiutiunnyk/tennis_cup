import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/user_creation_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/user_creation_state.dart';

class CreatePlayerForm extends StatefulWidget {
  const CreatePlayerForm({super.key});

  @override
  State<CreatePlayerForm> createState() => _CreatePlayerFormState();
}

class _CreatePlayerFormState extends State<CreatePlayerForm> {
  final _formKey = GlobalKey<FormState>();
  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _patronymicCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  bool _obscure = true;
  DateTime? _birthDate;
  String? _gender;

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _patronymicCtrl.dispose();
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _loginCtrl,
            decoration: const InputDecoration(labelText: 'Login / Email'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) => (v == null || v.length < 8) ? 'Min 8 characters' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _firstNameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'First name'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _lastNameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Last name'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _patronymicCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Patronymic (optional)'),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _birthDate == null
                  ? 'Birth date (optional)'
                  : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
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
            decoration: const InputDecoration(labelText: 'Gender (optional)'),
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
            decoration: const InputDecoration(labelText: 'Country (optional)'),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _cityCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'City (optional)'),
          ),
          const SizedBox(height: 24),
          BlocBuilder<UserCreationCubit, UserCreationState>(
            builder: (context, state) => FilledButton(
              onPressed: state is UserCreationLoading ? null : _submit,
              child: state is UserCreationLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Register Player'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  String? _isoDate() {
    if (_birthDate == null) return null;
    final d = _birthDate!;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<UserCreationCubit>().registerPlayer(
          login: _loginCtrl.text.trim(),
          password: _passwordCtrl.text,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          patronymicName: _patronymicCtrl.text.trim().isEmpty
              ? null
              : _patronymicCtrl.text.trim(),
          birthDate: _isoDate(),
          gender: _gender,
          country: _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim(),
          city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        );
  }
}
