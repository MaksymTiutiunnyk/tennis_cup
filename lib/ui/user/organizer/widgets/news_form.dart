import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/organizer_news_cubit.dart';

final _displayFmt = DateFormat('dd MMM yyyy HH:mm');

class NewsForm extends StatefulWidget {
  final News? existing;

  const NewsForm({super.key, this.existing});

  @override
  State<NewsForm> createState() => _NewsFormState();
}

class _NewsFormState extends State<NewsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;

  DateTime _timestamp = DateTime.now();
  String _importance = 'REGULAR';
  File? _pickedImage;
  bool _removeImage = false;
  bool _submitting = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _bodyCtrl = TextEditingController(text: e?.text ?? '');
    if (e != null) {
      _timestamp = e.date;
      _importance = e.isInteresting ? 'INTERESTING' : 'REGULAR';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() {
        _pickedImage = File(picked.path);
        _removeImage = false;
      });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime(2018),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (time == null) return;
    setState(() {
      _timestamp =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    setState(() => _submitting = true);

    final cubit = context.read<OrganizerNewsCubit>();
    if (_isEdit) {
      await cubit.update(
        widget.existing!.id,
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        newsTimestamp: _timestamp,
        importance: _importance,
        removeImage: _removeImage,
        image: _pickedImage,
      );
    } else {
      await cubit.create(
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        newsTimestamp: _timestamp,
        importance: _importance,
        image: _pickedImage,
      );
    }

    if (mounted) {
      setState(() => _submitting = false);
      if (cubit.state is! OrgNewsError) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingImageUrl = widget.existing?.imageUrl ?? '';
    final hasExistingImage =
        existingImageUrl.isNotEmpty && !_removeImage && _pickedImage == null;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit News' : 'New News')),
      body: BlocListener<OrganizerNewsCubit, OrganizerNewsState>(
        listener: (context, state) {
          if (state is OrgNewsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                maxLength: 255,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bodyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                maxLength: 10000,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _importance,
                decoration: const InputDecoration(labelText: 'Importance'),
                items: const ['REGULAR', 'INTERESTING']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) => setState(() => _importance = v!),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date & time'),
                subtitle: Text(_displayFmt.format(_timestamp)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 12),
              if (_pickedImage != null) ...[
                _ImagePreview(
                  image: _pickedImage!,
                  onRemove: () => setState(() => _pickedImage = null),
                ),
                const SizedBox(height: 8),
              ] else if (hasExistingImage) ...[
                _NetworkImagePreview(
                  url: existingImageUrl,
                  onRemove: () => setState(() => _removeImage = true),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  (_pickedImage != null || hasExistingImage)
                      ? 'Change image'
                      : 'Add image',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEdit ? 'Save' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _ImagePreview({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            image,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.black54),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}

class _NetworkImagePreview extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;

  const _NetworkImagePreview({required this.url, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Image.asset(
                'assets/default_image.jpg',
                fit: BoxFit.cover,
              );
            },
            loadingBuilder: (_, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.black54),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}
