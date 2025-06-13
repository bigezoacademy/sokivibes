import 'package:flutter/material.dart';

class SongVersionTile extends StatelessWidget {
  final String genre;
  final String fileUrl;
  final int votes;
  final int likes;
  final VoidCallback onPlay;
  final VoidCallback onDownload;
  final VoidCallback onLike;
  final VoidCallback onShare;

  const SongVersionTile({
    super.key,
    required this.genre,
    required this.fileUrl,
    required this.votes,
    required this.likes,
    required this.onPlay,
    required this.onDownload,
    required this.onLike,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.music_note,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    genre,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(icon: Icon(Icons.play_arrow), onPressed: onPlay),
                IconButton(icon: Icon(Icons.download), onPressed: onDownload),
                IconButton(
                    icon: Icon(Icons.favorite_border), onPressed: onLike),
                IconButton(icon: Icon(Icons.share), onPressed: onShare),
                const SizedBox(width: 8),
                Text('Likes: $likes'),
                const SizedBox(width: 16),
                Text('Votes: $votes'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
