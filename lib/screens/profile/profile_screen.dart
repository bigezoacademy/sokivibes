import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    // Try to get createdAt from metadata (if available)
    String createdAt = '';
    if (user?.metadata.creationTime != null) {
      final dt = user!.metadata.creationTime!;
      createdAt = '${dt.day.toString().padLeft(2, '0')} '
          '${_monthName(dt.month)} ${dt.year} at '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')} UTC';
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 90,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 120)
                  : null,
            ),
            const SizedBox(height: 24),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              children: [
                TableRow(children: [
                  const Text('Name:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(user?.displayName ?? 'your name'),
                ]),
                TableRow(children: [
                  const Text('Email:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(user?.email ?? ''),
                ]),
                TableRow(children: [
                  const Text('Role:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(authProvider.isAdmin ? 'admin' : 'user'),
                ]),
                TableRow(children: [
                  const Text('Created:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(createdAt.isNotEmpty ? createdAt : '-'),
                ]),
                TableRow(children: [
                  const Text('Photo URL:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(user?.photoURL ?? '-'),
                ]),
              ],
            ),
            const SizedBox(height: 16),
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

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }
}
