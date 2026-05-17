import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/core/widgets/player_avatar.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/user_edit_cubit.dart';

class AvatarSection extends StatelessWidget {
  final UserEditLoaded state;

  const AvatarSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<UserEditCubit>();
    final hasPhoto = state.pendingAvatarBytes != null ||
        (!state.avatarRemoved && state.user.imageUrl.isNotEmpty);

    return Column(
      children: [
        _buildPreview(context),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: state.saving ? null : cubit.pickAvatar,
              icon: const Icon(Icons.photo_camera, size: 18),
              label: Text(hasPhoto ? s.changePhoto : s.addPhoto),
            ),
            if (hasPhoto)
              OutlinedButton.icon(
                onPressed: state.saving ? null : cubit.removeAvatar,
                icon: const Icon(Icons.close, size: 18),
                label: Text(s.remove),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    if (state.pendingAvatarBytes != null) {
      return CircleAvatar(
        radius: 48,
        backgroundImage: MemoryImage(state.pendingAvatarBytes!),
      );
    }
    if (!state.avatarRemoved && state.user.imageUrl.isNotEmpty) {
      return PlayerAvatar(imageUrl: state.user.imageUrl, radius: 48);
    }
    return CircleAvatar(
      radius: 48,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(Icons.person,
          size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}
