import 'package:flutter/material.dart';

import 'data.dart';
import 'profile_header.dart';
import 'info_row.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My profile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: Column(
        children: [
          const ProfileHeader(name: myName, university: myUniversity),
          for (final fact in facts)
            InfoRow(label: fact.label, value: fact.value),
        ],
      ),
    );
  }
}
