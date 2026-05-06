import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/combined_user.dart';
import 'package:tennis_cup/ui/core/widgets/player_avatar.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/users_search_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/edit_player_dialog.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/role_chip.dart';

class UserSearchTile extends StatelessWidget {
  final CombinedUser user;

  const UserSearchTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      leading: PlayerAvatar(imageUrl: user.avatarUrl, radius: 22),
      title: Text(user.fullName),
      subtitle: Wrap(
        spacing: 4,
        runSpacing: 2,
        children: user.roles.map((r) => RoleChip(role: r)).toList(),
      ),
      onTap: user.isPlayer && user.playerId != null
          ? () => _showEditDialog(context)
          : null,
    );

    if (!user.isDeletable) return tile;

    return Dismissible(
      key: ValueKey(user.userId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) {
        context.read<UsersSearchCubit>().softDelete(user);
      },
      child: tile,
    );
  }

  void _showEditDialog(BuildContext context) {
    final cubit = context.read<UsersSearchCubit>();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => BlocProvider.value(
        value: cubit,
        child: EditPlayerDialog(user: user),
      ),
    );
  }
}
