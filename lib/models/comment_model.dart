class Comment {
  final String id;
  final String songId;
  final String userId;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.songId,
    required this.userId,
    required this.text,
    required this.timestamp,
  });
}
