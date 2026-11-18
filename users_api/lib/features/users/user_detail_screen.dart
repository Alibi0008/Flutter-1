import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          _row('Username', '@${user.username}'),
          _row('Email', user.email),
          // Practice 12 gives these url_launcher.
          _row('Phone', user.phone, onTap: () {}),
          _row('Website', user.website ?? '-', onTap: () {}),
          _row('Address', '${a.street}, ${a.suite}\n${a.city} ${a.zipcode}'),
          _row('Geo', '${a.geo.lat}, ${a.geo.lng}'),
          _row('Company', '${user.company.name}\n${user.company.catchPhrase}'),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {VoidCallback? onTap}) =>
      ListTile(title: Text(label), subtitle: Text(value), onTap: onTap);
}
