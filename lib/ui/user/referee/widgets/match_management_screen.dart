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
        final msg = state is RefereeMatchReady
            ? state.notification
            : (state as RefereeMatchError).message;
        if (msg != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(msg)));
        }
      },
      builder: (context, state) {
        if (state is RefereeMatchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is RefereeMatchError) {
          return Center(child: Text(state.message));
        }
        if (state is! RefereeMatchReady) return const SizedBox();
        return MatchBody(state: state);
      },
    );
  }
}
