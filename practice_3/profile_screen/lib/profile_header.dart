import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  final String name;
  final String university;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Image.asset('assets/images/IMG_2177.png', width: 100, height: 100),
          const SizedBox(height: 12),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontFamily: 'MyFont'),
          ),
          Text(university, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
