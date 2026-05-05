import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/organizer_management_cubit.dart';

class DeleteOrganizerSection extends StatefulWidget {
  const DeleteOrganizerSection({super.key});

  @override
  State<DeleteOrganizerSection> createState() => _DeleteOrganizerSectionState();
}

class _DeleteOrganizerSectionState extends State<DeleteOrganizerSection> {
  final _idCtrl = TextEditingController();

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delete organizer',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'No list endpoint is available yet — enter the organizer\'s ID directly.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _idCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Organizer ID'),
              ),
            ),
            const SizedBox(width: 12),
            BlocBuilder<OrganizerManagementCubit, OrganizerManagementState>(
              builder: (context, state) => FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed:
                    state is OrgManagementLoading ? null : _confirmDelete,
                child: const Text('Delete'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmDelete() {
    final id = int.tryParse(_idCtrl.text.trim());
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid organizer ID')),
      );
      return;
    }
    showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete organizer'),
        content: Text('Delete organizer with ID $id? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<OrganizerManagementCubit>().deleteOrganizer(id);
      }
    });
  }
}
