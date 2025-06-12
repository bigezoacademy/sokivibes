import 'package:flutter/material.dart';

class RequestServiceScreen extends StatelessWidget {
  const RequestServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement request service form and Firestore/email logic
    return Scaffold(
      appBar: AppBar(title: const Text('Request Song Service')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Your Name'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Request Details'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Submit to Firestore or launch mailto
              },
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
