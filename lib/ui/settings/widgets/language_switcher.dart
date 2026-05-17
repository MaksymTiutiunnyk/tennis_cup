import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/ui/settings/view_models/language_cubit.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        final cubit = context.read<LanguageCubit>();
        return SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'en', label: Text('EN')),
            ButtonSegment(value: 'uk', label: Text('UK')),
          ],
          selected: {locale.languageCode},
          onSelectionChanged: (set) => cubit.setLocale(Locale(set.first)),
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
      },
    );
  }
}
