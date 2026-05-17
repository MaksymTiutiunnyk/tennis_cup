import 'package:flutter/material.dart';
import 'package:tennis_cup/generated/l10n.dart';

class AsyncStateWidget extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget child;

  const AsyncStateWidget({
    super.key,
    required this.isLoading,
    required this.child,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: colorScheme.error, size: 48),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.error),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(S.of(context).retry),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return child;
  }
}
