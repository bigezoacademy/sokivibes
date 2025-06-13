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
import 'package:flutter/services.dart';

class SongDetailScreen extends StatelessWidget {
  final Song? song;
  const SongDetailScreen({super.key, this.song});

  @override
  Widget build(BuildContext context) {
    // Fix: Try to get the song from ModalRoute if not passed directly
    final Song? effectiveSong =
        song ?? ModalRoute.of(context)?.settings.arguments as Song?;
    if (effectiveSong == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Song Details')),
        body: const Center(child: Text('No song selected.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(effectiveSong.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (effectiveSong.description.isNotEmpty)
            Text(effectiveSong.description,
                style: Theme.of(context).textTheme.bodyLarge),
          if (effectiveSong.description.isNotEmpty) const SizedBox(height: 16),
          Text('Original Version',
              style: Theme.of(context).textTheme.titleMedium),
          AudioPlayerWidget(url: effectiveSong.originalUrl),
          const SizedBox(height: 16),
          Text('AI Versions', style: Theme.of(context).textTheme.titleMedium),
          ...effectiveSong.versions
              .where((v) =>
                  v.fileUrl != effectiveSong.originalUrl &&
                  v.fileUrl.isNotEmpty)
              .map((v) => SongVersionTile(
                    genre: v.genre,
                    fileUrl: v.fileUrl,
                    votes: v.votes,
                    likes: v.likes,
                    onPlay: () {
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
                        await StorageService().downloadSong(
                            v.fileUrl, effectiveSong.title + '_' + v.genre);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Downloaded ${effectiveSong.title} (${v.genre})')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Storage permission denied.')),
                        );
                      }
                    },
                    onLike: () {
                      final auth =
                          Provider.of<AuthProvider>(context, listen: false);
                      if (!auth.isLoggedIn) {
                        Navigator.pushNamed(context, '/login');
                      } else {
                        // Like logic for version
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Liked (implement logic)')),
                        );
                      }
                    },
                    onShare: () {
                      final shareText =
                          'Check out this song on Soki-Vibes: ${effectiveSong.title}';
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SizedBox(
                          height: 160,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Share this song',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              SelectableText(shareText),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.copy),
                                label: const Text('Copy Link'),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: shareText));
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Link copied to clipboard!')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),
          const SizedBox(height: 24),
          Text('Comments', style: Theme.of(context).textTheme.titleMedium),
          Consumer<CommentProvider>(
            builder: (context, commentProvider, _) {
              commentProvider.fetchComments(effectiveSong.id);
              final comments = commentProvider.comments;
              return Column(
                children: [
                  ...comments.map((c) => CommentBox(
                        userName: c.userId,
                        comment: c.text,
                        date: c.timestamp.toString(),
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
                                        c.id, effectiveSong.id);
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
                                await commentProvider.addComment(
                                    effectiveSong.id,
                                    auth.user!.uid,
                                    controller.text.trim());
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
