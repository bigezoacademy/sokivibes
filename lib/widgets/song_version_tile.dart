import 'package:flutter/material.dart';

class SongVersionTile extends StatelessWidget {
  final String genre;
  final String fileUrl;
  final int votes;
  final int likes;
  final VoidCallback onPlay;
  final VoidCallback onDownload;
  final VoidCallback onLike;
  final VoidCallback onVote;

  const SongVersionTile({
    super.key,
    required this.genre,
    required this.fileUrl,
    required this.votes,
    required this.likes,
    required this.onPlay,
    required this.onDownload,
    required this.onLike,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.music_note),
      title: Text(genre),
      subtitle: Row(
        children: [
          IconButton(icon: Icon(Icons.play_arrow), onPressed: onPlay),
          IconButton(icon: Icon(Icons.download), onPressed: onDownload),
          IconButton(icon: Icon(Icons.favorite_border), onPressed: onLike),
          IconButton(icon: Icon(Icons.arrow_upward), onPressed: onVote),
          Text('Likes: $likes'),
          Text('Votes: $votes'),
        ],
      ),
    );
  }
}
