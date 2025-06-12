import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Downloads')),
      body: FutureBuilder<List<File>>(
        future: _getDownloadedFiles(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final files = snapshot.data!;
          if (files.isEmpty) {
            return const Center(child: Text('No downloads yet.'));
          }
          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(file.path.split(Platform.pathSeparator).last),
                onTap: () {
                  // Play downloaded file
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => SizedBox(
                      height: 120,
                      child: Center(
                        child: Text(
                            'Audio player for offline file: ${file.path.split(Platform.pathSeparator).last}'),
                      ),
                    ),
                  );
                  // For real playback, use AudioPlayerWidget with file.path
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<File>> _getDownloadedFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${dir.path}/SokiVibes/downloads');
    if (!downloadsDir.existsSync()) return [];
    return downloadsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.mp3'))
        .toList();
  }
}
