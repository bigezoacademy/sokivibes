import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Show user stats, liked/voted/commented songs, avatar, nickname
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 48),
            ),
            const SizedBox(height: 16),
            Text('Nickname', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Total Likes: 0'),
            Text('Total Votes: 0'),
            Text('Total Comments: 0'),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                  child: Text('Liked and commented songs will appear here.')),
            ),
          ],
        ),
      ),
    );
  }
}
