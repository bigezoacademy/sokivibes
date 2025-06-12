class Song {
  final String id;
  final String title;
  final String description;
  final List<String> genres;
  final String originalUrl;
  final List<SongVersion> versions;
  final DateTime timestamp;

  Song({
    required this.id,
    required this.title,
    required this.description,
    required this.genres,
    required this.originalUrl,
    required this.versions,
    required this.timestamp,
  });
}

class SongVersion {
  final String genre;
  final String fileUrl;
  final int votes;
  final int likes;

  SongVersion({
    required this.genre,
    required this.fileUrl,
    required this.votes,
    required this.likes,
  });
}
