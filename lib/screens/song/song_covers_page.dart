import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // For web download
import '../../models/song_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/song_provider.dart';
import '../../services/permission_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/bottom_nav_bar.dart';

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
      appBar:
          AppBar(title: const Text('Covers')), // Remove song title from AppBar
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Text(
              song.title,
              style: const TextStyle(
                color: Colors.pink,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          // Original song card at the top
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: const Color.fromARGB(255, 77, 56, 66),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Music icon column
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0, top: 8),
                    child: Icon(Icons.music_note, color: Colors.pink, size: 32),
                  ),
                  // Details and actions column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "Original" label
                        // Genre row
                        // Genre row
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Original/ raw',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color.fromARGB(179, 255, 255, 255),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Actions row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                try {
                                  final hasPermission =
                                      await PermissionService()
                                          .requestStoragePermission();
                                  if (hasPermission) {
                                    await StorageService().downloadSong(
                                        song.originalUrl, song.title);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Downloaded ${song.title}')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Storage permission denied.')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Download failed: ${e.toString()}')),
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
                      ],
                    ),
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
                color: Colors.white.withOpacity(0.1),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Music icon column
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0, top: 8),
                        child: Icon(Icons.music_note,
                            color: Colors.pink, size: 32),
                      ),
                      // Details and actions column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "Cover" label row
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Cover',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color.fromARGB(
                                          255, 255, 255, 255), // white
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Likes row (votes removed)
                            Row(
                              children: [
                                Text('Likes: ${cover.likes}',
                                    style:
                                        const TextStyle(color: Colors.white70)),
                              ],
                            ),
                            // Actions row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
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
                                    if (kIsWeb) {
                                      final url = cover.fileUrl;
                                      final anchor =
                                          html.AnchorElement(href: url)
                                            ..setAttribute(
                                                'download',
                                                song.title +
                                                    '_' +
                                                    cover.genre +
                                                    '.mp3')
                                            ..target = 'blank';
                                      html.document.body!.append(anchor);
                                      anchor.click();
                                      anchor.remove();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Download started in browser.')),
                                      );
                                    } else {
                                      try {
                                        final hasPermission =
                                            await PermissionService()
                                                .requestStoragePermission();
                                        if (hasPermission) {
                                          await StorageService().downloadSong(
                                              cover.fileUrl,
                                              song.title + '_' + cover.genre);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Downloaded ${song.title} (${cover.genre})')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Storage permission denied.')),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Download failed: ${e.toString()}')),
                                        );
                                      }
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(content: Text('Liked!')),
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
                                      Navigator.pushNamed(
                                          context, '/song-detail',
                                          arguments: song);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  tooltip: 'Share',
                                  onPressed: () {
                                    final shareText =
                                        'Check out this song ${song.title} on Soki-Vibes: https://sokivibes.web.app/';
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) => SizedBox(
                                        height: 160,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text('Share this song',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 12),
                                            SelectableText(shareText),
                                            const SizedBox(height: 12),
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.copy),
                                              label: const Text('Copy Link'),
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: shareText));
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Link copied to clipboard!')),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // or set to the appropriate index for navigation
        onTap: (index) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          // Optionally, implement navigation logic here if needed
        },
        isAdmin: Provider.of<AuthProvider>(context, listen: false).isAdmin,
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
