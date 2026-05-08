import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/users_search_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/users_search_state.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/create_user_fab.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/user_search_tile.dart';

class OrganizerUsersTab extends StatelessWidget {
  const OrganizerUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UsersSearchCubit(
        adminRepository: ServiceLocator.adminRepository,
        playerRepository: ServiceLocator.playerRepository,
      ),
      child: const _OrganizerUsersTabBody(),
    );
  }
}

class _OrganizerUsersTabBody extends StatefulWidget {
  const _OrganizerUsersTabBody();

  @override
  State<_OrganizerUsersTabBody> createState() => _OrganizerUsersTabBodyState();
}

class _OrganizerUsersTabBodyState extends State<_OrganizerUsersTabBody> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<UsersSearchCubit>().search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsersSearchCubit, UsersSearchState>(
      listener: (context, state) {
        if (state is UsersSearchLoaded && state.pendingDelete != null) {
          final user = state.pendingDelete!;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.fullName} removed'),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  context.read<UsersSearchCubit>().undoDelete();
                },
              ),
            ),
          );
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.words,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search by first or last name',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _controller.clear();
                            context.read<UsersSearchCubit>().search('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<UsersSearchCubit, UsersSearchState>(
                builder: (context, state) => switch (state) {
                  UsersSearchIdle() => const Center(
                      child: Text('Enter a name to search'),
                    ),
                  UsersSearchLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  UsersSearchLoaded(users: final users) when users.isEmpty =>
                    const Center(child: Text('No users found')),
                  UsersSearchLoaded(users: final users) => ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (_, i) => UserSearchTile(user: users[i]),
                    ),
                  UsersSearchError() => const Center(
                      child: Text('Something went wrong'),
                    ),
                },
              ),
            ),
          ],
        ),
        floatingActionButton: const CreateUserFab(),
      ),
    );
  }
}
