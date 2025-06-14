import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/song_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/comment_provider.dart';
import '../../widgets/comment_box.dart';
import 'package:flutter/services.dart';

class SongDetailScreen extends StatefulWidget {
  final Song? song;
  const SongDetailScreen({super.key, this.song});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  late Song effectiveSong;
  late TextEditingController _controller;
  bool _isLoading = false;
  double _commentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final song =
          widget.song ?? ModalRoute.of(context)?.settings.arguments as Song?;
      if (song != null) {
        setState(() => effectiveSong = song);
        Provider.of<CommentProvider>(context, listen: false)
            .fetchComments(song.id);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addComment(
      CommentProvider commentProvider, String userId, String text) async {
    setState(() {
      _isLoading = true;
      _commentProgress = 0.05;
    });
    // Simulate progress for UX (Firestore is fast, so we animate for effect)
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return;
      setState(() {
        _commentProgress = i / 10;
      });
    }
    await commentProvider.addComment(effectiveSong.id, userId, text);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _commentProgress = 0.0;
    });
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment added!')),
    );
    // Force refresh of the FutureBuilder by calling setState
    setState(() {});
  }

  String _formatCommentTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    // If effectiveSong is not set yet, show loading
    if (widget.song == null &&
        ModalRoute.of(context)?.settings.arguments == null) {
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
          // Metadata section
          Text('Song Metadata', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Table(
            columnWidths: const {0: IntrinsicColumnWidth()},
            border: const TableBorder(
              horizontalInside: BorderSide(
                color: Color.fromARGB(255, 96, 96, 96), // dark-grey
                width: 1,
              ),
            ),
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromARGB(255, 96, 96, 96), // dark-grey
                      width: 1,
                    ),
                  ),
                ),
                children: [
                  const Text(
                    'Title:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(effectiveSong.title),
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromARGB(255, 96, 96, 96), // dark-grey
                      width: 1,
                    ),
                  ),
                ),
                children: [
                  const Text(
                    'Genres:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(effectiveSong.genres.isNotEmpty
                      ? effectiveSong.genres.join(', ')
                      : '-'),
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromARGB(255, 96, 96, 96), // dark-grey
                      width: 1,
                    ),
                  ),
                ),
                children: [
                  const Text(
                    'Uploaded:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(effectiveSong.timestamp.toString()),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text('Comments', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(
            height: 350,
            child: FutureBuilder<List<CommentWithUser>>(
              future: fetchCommentsWithUsers(effectiveSong.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, i) {
                    final c = comments[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: c.userPhotoUrl != null &&
                                    c.userPhotoUrl!.isNotEmpty
                                ? NetworkImage(c.userPhotoUrl!)
                                : null,
                            child: c.userPhotoUrl == null ||
                                    c.userPhotoUrl!.isEmpty
                                ? const Icon(Icons.person, size: 22)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        c.userName ?? 'User',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.pink,
                                            fontSize: 15),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatCommentTime(c.timestamp),
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    c.text,
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (!auth.isLoggedIn) {
                return TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Log in to comment'),
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration:
                          const InputDecoration(hintText: 'Add a comment...'),
                      enabled: !_isLoading,
                    ),
                  ),
                  _isLoading
                      ? Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              LinearProgressIndicator(
                                value: _commentProgress > 0
                                    ? _commentProgress
                                    : null,
                                minHeight: 3,
                                color: Colors.pink,
                                backgroundColor: Colors.pink.shade100,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _commentProgress > 0
                                    ? 'Uploading: ${(100 * _commentProgress).toStringAsFixed(0)}%'
                                    : 'Uploading...',
                                style: const TextStyle(
                                    color: Colors.pink,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () async {
                            if (_controller.text.trim().isNotEmpty) {
                              final commentProvider =
                                  Provider.of<CommentProvider>(context,
                                      listen: false);
                              final auth = Provider.of<AuthProvider>(context,
                                  listen: false);
                              await _addComment(commentProvider, auth.user!.uid,
                                  _controller.text.trim());
                            }
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

class CommentWithUser {
  final String id;
  final String userId;
  final String text;
  final DateTime timestamp;
  final String? userName;
  final String? userPhotoUrl;
  CommentWithUser({
    required this.id,
    required this.userId,
    required this.text,
    required this.timestamp,
    this.userName,
    this.userPhotoUrl,
  });
}

Future<List<CommentWithUser>> fetchCommentsWithUsers(String songId) async {
  final commentsSnap = await FirebaseFirestore.instance
      .collection('comments')
      .where('songId', isEqualTo: songId)
      .orderBy('timestamp', descending: true)
      .get();
  final comments = commentsSnap.docs;
  // Get unique userIds
  final userIds = comments.map((c) => c['userId'] as String).toSet();
  // Fetch all user docs in parallel
  final userDocs = <String, Map<String, dynamic>>{};
  for (final userId in userIds) {
    final userSnap =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userSnap.exists) {
      userDocs[userId] = userSnap.data()!;
    }
  }
  return comments.map((doc) {
    final data = doc.data();
    final user = userDocs[data['userId']];
    return CommentWithUser(
      id: doc.id,
      userId: data['userId'],
      text: data['text'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userName: user != null ? user['displayName'] as String? : null,
      userPhotoUrl: user != null ? user['photoURL'] as String? : null,
    );
  }).toList();
}
