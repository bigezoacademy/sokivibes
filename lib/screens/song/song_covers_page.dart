import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song_model.dart';
import '../../models/version_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/song_provider.dart';
import '../../services/permission_service.dart';
import '../../services/storage_service.dart';

class SongCoversPage extends StatelessWidget {
  final Song song;
  const SongCoversPage({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final covers =
        song.versions.where((v) => v.genre != song.genres.first).toList();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('Covers for ${song.title}')),
      body: covers.isEmpty
          ? const Center(child: Text('No covers available for this song.'))
          : ListView.builder(
              itemCount: covers.length,
              itemBuilder: (context, index) {
                final cover = covers[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(cover.genre),
                    subtitle: Row(
                      children: [
                        Text('Votes: ${cover.votes}'),
                        const SizedBox(width: 16),
                        Text('Likes: ${cover.likes}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => SizedBox(
                                height: 120,
                                child: Center(
                                  child: Text('Audio player UI here for cover'),
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () async {
                            final hasPermission = await PermissionService()
                                .requestStoragePermission();
                            if (hasPermission) {
                              await StorageService().downloadSong(cover.fileUrl,
                                  song.title + '_' + cover.genre);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Downloaded ${song.title} (${cover.genre})')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Storage permission denied.')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () async {
                            if (!auth.isLoggedIn) {
                              Navigator.pushNamed(context, '/login');
                            } else {
                              await songProvider.likeSong(
                                  song.id, auth.user!.uid);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Liked!')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          onPressed: () async {
                            if (!auth.isLoggedIn) {
                              Navigator.pushNamed(context, '/login');
                            } else {
                              await songProvider.voteSong(
                                  song.id, auth.user!.uid);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Voted!')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
