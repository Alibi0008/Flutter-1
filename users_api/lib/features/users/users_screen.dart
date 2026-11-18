import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';
import 'widgets/state_views.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const NewUserScreen())),
        child: const Icon(Icons.add),
      ),
      body: _body(m),
    );
  }

  Widget _body(UsersModel m) {
    // Spinner only on the first load; during pull-to-refresh the list
    // stays and RefreshIndicator shows its own spinner.
    if (m.loading && m.items.isEmpty) return const LoadingView();

    // Exhaustive: ApiException is sealed, so no default.
    return switch (m.error) {
      null => UserList(m.items),
      NoConnectionException() => Offline(onRetry: m.load),
      NotFoundException() || UnauthorizedException() => const RequestError(
        'The request was rejected.',
      ),
      ServerException(:final status) => ServerError(status, onRetry: m.load),
      BadResponseException() => const GenericError(),
    };
  }
}

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    final m = context.read<UsersModel>();
    return RefreshIndicator(
      onRefresh: m.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final u = users[i];
          return ListTile(
            title: Text(u.name),
            subtitle: Text('${u.email}\n${u.address.city}'),
            isThreeLine: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UserDetailScreen(user: u),
              ),
            ),
          );
        },
      ),
    );
  }
}
