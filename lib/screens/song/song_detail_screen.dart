import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song_model.dart';
import '../../widgets/song_version_tile.dart';
import '../../widgets/audio_player_widget.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../services/permission_service.dart';
import '../../providers/comment_provider.dart';
import '../../widgets/comment_box.dart';

class SongDetailScreen extends StatelessWidget {
  final Song? song;
  const SongDetailScreen({super.key, this.song});

  @override
  Widget build(BuildContext context) {
    if (song == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Song Details')),
        body: const Center(child: Text('No song selected.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(song!.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(song!.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text('Original Version',
              style: Theme.of(context).textTheme.titleMedium),
          AudioPlayerWidget(url: song!.originalUrl),
          const SizedBox(height: 16),
          Text('AI Versions', style: Theme.of(context).textTheme.titleMedium),
          ...song!.versions.map((v) => SongVersionTile(
                genre: v.genre,
                fileUrl: v.fileUrl,
                votes: v.votes,
                likes: v.likes,
                onPlay: () {
                  // Play this version
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => SizedBox(
                      height: 120,
                      child: AudioPlayerWidget(url: v.fileUrl),
                    ),
                  );
                },
                onDownload: () async {
                  final hasPermission =
                      await PermissionService().requestStoragePermission();
                  if (hasPermission) {
                    await StorageService()
                        .downloadSong(v.fileUrl, song!.title + '_' + v.genre);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Downloaded ${song!.title} (${v.genre})')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Storage permission denied.')),
                    );
                  }
                },
                onLike: () {
                  // Like this version (prompt login if needed)
                  final auth =
                      Provider.of<AuthProvider>(context, listen: false);
                  if (!auth.isLoggedIn) {
                    Navigator.pushNamed(context, '/login');
                  } else {
                    // Like logic for version
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Liked (implement logic)')),
                    );
                  }
                },
                onVote: () {
                  // Vote for this version (prompt login if needed)
                  final auth =
                      Provider.of<AuthProvider>(context, listen: false);
                  if (!auth.isLoggedIn) {
                    Navigator.pushNamed(context, '/login');
                  } else {
                    // Vote logic for version
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voted (implement logic)')),
                    );
                  }
                },
              )),
          const SizedBox(height: 24),
          Text('Comments', style: Theme.of(context).textTheme.titleMedium),
          Consumer<CommentProvider>(
            builder: (context, commentProvider, _) {
              commentProvider.fetchComments(song!.id);
              final comments = commentProvider.comments;
              return Column(
                children: [
                  ...comments.map((c) => CommentBox(
                        userName: c
                            .userId, // Replace with user display name if available
                        comment: c.text,
                        date: c.timestamp.toString(), // Format as needed
                        isAdmin:
                            Provider.of<AuthProvider>(context, listen: false)
                                .isAdmin,
                        onDelete:
                            Provider.of<AuthProvider>(context, listen: false)
                                        .isAdmin ||
                                    c.userId ==
                                        Provider.of<AuthProvider>(context,
                                                listen: false)
                                            .user
                                            ?.uid
                                ? () async {
                                    await commentProvider.deleteComment(
                                        c.id, song!.id);
                                  }
                                : null,
                      )),
                  const SizedBox(height: 8),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (!auth.isLoggedIn) {
                        return TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          child: const Text('Log in to comment'),
                        );
                      }
                      final controller = TextEditingController();
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                  hintText: 'Add a comment...'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () async {
                              if (controller.text.trim().isNotEmpty) {
                                await commentProvider.addComment(song!.id,
                                    auth.user!.uid, controller.text.trim());
                                controller.clear();
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
