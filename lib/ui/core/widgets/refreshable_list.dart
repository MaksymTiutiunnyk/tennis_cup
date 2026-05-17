import 'package:flutter/material.dart';

class RefreshableList<T> extends StatelessWidget {
  final List<T> items;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext, T) itemBuilder;
  final Widget emptyWidget;
  final EdgeInsetsGeometry? padding;

  const RefreshableList({
    super.key,
    required this.items,
    required this.onRefresh,
    required this.itemBuilder,
    required this.emptyWidget,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(child: Center(child: emptyWidget)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount: items.length,
        itemBuilder: (context, i) => itemBuilder(context, items[i]),
      ),
    );
  }
}
