import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Only show for admin users, upload new songs, manage comments, view analytics
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Column(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload New Song'),
            onPressed: () {
              // TODO: Open file picker and upload logic
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                Center(child: Text('Analytics and comment management here.')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Open upload song dialog
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Song',
      ),
    );
  }
}
