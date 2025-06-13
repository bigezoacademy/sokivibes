import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/song_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/song_provider.dart';
import '../../services/permission_service.dart';
import '../../services/storage_service.dart';

class SongCoversPage extends StatelessWidget {
  final Song song;
  const SongCoversPage({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    // Show the original song at the top, then covers below
    // Fix: covers should be all versions except the originalUrl, not just genre != genres.first
    final covers = song.versions
        .where((v) => v.fileUrl != song.originalUrl && v.fileUrl.isNotEmpty)
        .toList();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('Covers for ${song.title}')),
      body: ListView(
        children: [
          // Original song card at the top
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.pink.shade50,
            child: ListTile(
              leading: const Icon(Icons.music_note, color: Colors.pink),
              title: Text('${song.title} (Original)',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(song.genres.isNotEmpty ? song.genres.first : ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => SongPlayerBottomSheet(
                            url: song.originalUrl, title: song.title),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () async {
                      final hasPermission =
                          await PermissionService().requestStoragePermission();
                      if (hasPermission) {
                        await StorageService()
                            .downloadSong(song.originalUrl, song.title);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloaded ${song.title}')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Storage permission denied.')),
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
                        await songProvider.likeSong(song.id, auth.user!.uid);
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
                        await songProvider.voteSong(song.id, auth.user!.uid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Voted!')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () {
                      if (!auth.isLoggedIn) {
                        Navigator.pushNamed(context, '/login');
                      } else {
                        Navigator.pushNamed(context, '/song-detail',
                            arguments: song);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          // Covers below
          if (covers.isEmpty)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No covers available for this song.'),
            )),
          ...covers.map((cover) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.white
                    .withOpacity(0.1), // Transparent white background
                child: ListTile(
                  leading: const Icon(Icons.music_note, color: Colors.pink),
                  title: Text('${song.title} (AI Cover)',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Row(
                    children: [
                      Text('Votes: \\${cover.votes}'),
                      const SizedBox(width: 16),
                      Text('Likes: \\${cover.likes}'),
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
                            builder: (_) => SongPlayerBottomSheet(
                              url: cover.fileUrl,
                              title: song.title + ' (AI Cover)',
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
                            await StorageService().downloadSong(
                                cover.fileUrl, song.title + '_' + cover.genre);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Downloaded ${song.title} (${cover.genre})')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Storage permission denied.')),
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
                      IconButton(
                        icon: const Icon(Icons.comment),
                        onPressed: () {
                          if (!auth.isLoggedIn) {
                            Navigator.pushNamed(context, '/login');
                          } else {
                            Navigator.pushNamed(context, '/song-detail',
                                arguments: song);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// SongPlayerBottomSheet widget for playing audio (to be implemented)
class SongPlayerBottomSheet extends StatefulWidget {
  final String url;
  final String title;
  const SongPlayerBottomSheet(
      {super.key, required this.url, required this.title});

  @override
  State<SongPlayerBottomSheet> createState() => _SongPlayerBottomSheetState();
}

class _SongPlayerBottomSheetState extends State<SongPlayerBottomSheet> {
  late AudioPlayer _player;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setUrl(widget.url);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load audio.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else ...[
              StreamBuilder<Duration?>(
                stream: _player.durationStream,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (context, posSnapshot) {
                      final position = posSnapshot.data ?? Duration.zero;
                      return Column(
                        children: [
                          Slider(
                            min: 0,
                            max: duration.inMilliseconds.toDouble(),
                            value: position.inMilliseconds
                                .clamp(0, duration.inMilliseconds)
                                .toDouble(),
                            onChanged: (value) {
                              _player
                                  .seek(Duration(milliseconds: value.toInt()));
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position)),
                              Text(_formatDuration(duration)),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10),
                    onPressed: () async {
                      final pos = await _player.position;
                      _player.seek(pos - const Duration(seconds: 10));
                    },
                  ),
                  StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snapshot) {
                      final state = snapshot.data;
                      final playing = state?.playing ?? false;
                      if (playing) {
                        return IconButton(
                          icon: const Icon(Icons.pause,
                              size: 32, color: Colors.pink),
                          onPressed: () => _player.pause(),
                        );
                      } else {
                        return IconButton(
                          icon: const Icon(Icons.play_arrow,
                              size: 32, color: Colors.pink),
                          onPressed: () => _player.play(),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10),
                    onPressed: () async {
                      final pos = await _player.position;
                      _player.seek(pos + const Duration(seconds: 10));
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
