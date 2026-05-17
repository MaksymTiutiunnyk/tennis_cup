import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';
import 'package:tennis_cup/ui/user/referee/widgets/match_body.dart';

class MatchManagementScreen extends StatelessWidget {
  const MatchManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RefereeMatchCubit, RefereeMatchState>(
      listenWhen: (_, curr) =>
          (curr is RefereeMatchReady && curr.notification != null) ||
          curr is RefereeMatchError,
      listener: (context, state) {
        if (state is RefereeMatchReady && state.notification != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.notification!)));
        } else if (state is RefereeMatchError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ));
        }
      },
      builder: (context, state) {
        if (state is RefereeMatchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is RefereeMatchError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      color: Theme.of(context).colorScheme.error, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is! RefereeMatchReady) return const SizedBox();
        return MatchBody(state: state);
      },
    );
  }
}
