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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage!),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              ElevatedButton(onPressed: onRetry, child: Text(S.of(context).retry)),
            ],
          ],
        ),
      );
    }
    return child;
  }
}
