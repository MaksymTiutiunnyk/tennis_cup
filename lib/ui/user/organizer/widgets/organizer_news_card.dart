import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/organizer_news_cubit.dart';

final _dateFmt = DateFormat('dd MMM');

class OrganizerNewsCard extends StatelessWidget {
  final News news;
  final VoidCallback onEdit;

  const OrganizerNewsCard({
    super.key,
    required this.news,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ImportanceBadge(isInteresting: news.isInteresting),
                const Spacer(),
                Text(
                  _dateFmt.format(news.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _confirmDelete(context),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(news.title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              news.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (news.imageUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  news.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete news item'),
        content: Text('Delete "${news.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OrganizerNewsCubit>().delete(news.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ImportanceBadge extends StatelessWidget {
  final bool isInteresting;
  const _ImportanceBadge({required this.isInteresting});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isInteresting ? Colors.amber.shade700 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isInteresting ? 'INTERESTING' : 'REGULAR',
        style: TextStyle(
          fontSize: 11,
          color: isInteresting ? Colors.white : Colors.grey.shade700,
        ),
      ),
    );
  }
}
