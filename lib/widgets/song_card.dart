import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SongCard extends StatelessWidget {
  final String title;
  final List<String> genres;
  final String coverUrl;
  final VoidCallback onPlay;
  final VoidCallback onDownload;
  final VoidCallback onLike;
  final VoidCallback onVote;
  final VoidCallback onComment;
  final VoidCallback onCovers;

  const SongCard({
    super.key,
    required this.title,
    required this.genres,
    required this.coverUrl,
    required this.onPlay,
    required this.onDownload,
    required this.onLike,
    required this.onVote,
    required this.onComment,
    required this.onCovers,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                coverUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.music_note, size: 64),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                        textStyle: Theme.of(context).textTheme.titleMedium,
                      )),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: genres
                        .map((g) => Chip(
                              label: Text(g, style: GoogleFonts.poppins()),
                              avatar: Text(_genreIcon(g)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: onPlay),
                      IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: onDownload),
                      IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: onLike),
                      IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          onPressed: onVote),
                      IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: onComment),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: onCovers,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        child: const Text('Covers'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _genreIcon(String genre) {
    switch (genre.toLowerCase()) {
      case 'r&b':
        return '🎤';
      case 'afrobeat':
        return '🔥';
      case 'zouk':
        return '🌊';
      default:
        return '🎵';
    }
  }
}
