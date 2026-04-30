import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/ui/settings/view_models/app_mode_cubit.dart';

class ModeSwitcher extends StatelessWidget {
  const ModeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final fg =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;

    return BlocBuilder<AppModeCubit, AppMode>(
      builder: (context, mode) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SegmentedButton<AppMode>(
            segments: const [
              ButtonSegment(
                value: AppMode.viewOnly,
                icon: Icon(Icons.live_tv_outlined),
              ),
              ButtonSegment(
                value: AppMode.playerManager,
                icon: Icon(Icons.person_outline),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (s) =>
                context.read<AppModeCubit>().switchTo(s.first),
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              foregroundColor: fg,
              selectedForegroundColor: fg,
              selectedBackgroundColor: fg.withValues(alpha: 0.2),
              side: BorderSide(color: fg.withValues(alpha: 0.4)),
              visualDensity: VisualDensity.compact,
            ),
          ),
        );
      },
    );
  }
}
