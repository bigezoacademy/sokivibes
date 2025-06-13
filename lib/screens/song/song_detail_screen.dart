import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      setState(() {
        _commentProgress = i / 10;
      });
    }
    await commentProvider.addComment(effectiveSong.id, userId, text);
    setState(() {
      _isLoading = false;
      _commentProgress = 0.0;
    });
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment added!')),
    );
    await commentProvider.fetchComments(effectiveSong.id);
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
          Consumer<CommentProvider>(
            builder: (context, commentProvider, _) {
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Comment deleted.')),
                                    );
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
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                  hintText: 'Add a comment...'),
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
                                      final auth = Provider.of<AuthProvider>(
                                          context,
                                          listen: false);
                                      await _addComment(
                                          commentProvider,
                                          auth.user!.uid,
                                          _controller.text.trim());
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
