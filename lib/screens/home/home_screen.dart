import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/song_provider.dart';
import '../../widgets/song_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../services/permission_service.dart';
import '../../providers/theme_mode_provider.dart';
import '../downloads/download_screen.dart';
import '../search/search_screen.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;
    final songProvider = Provider.of<SongProvider>(context);
    if (songProvider.songs.isEmpty) {
      songProvider.fetchSongs();
    }
    final songs = songProvider.songs;
    final List<Widget> _pages = [
      // Home
      Scaffold(
        appBar: AppBar(
          title: const Text('Soki-Vibes'),
          actions: [
            IconButton(
              icon: Icon(Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode),
              tooltip: 'Toggle Theme',
              onPressed: () {
                Provider.of<ThemeModeProvider>(context, listen: false)
                    .toggleTheme();
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                // TODO: Implement sorting logic
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'latest', child: Text('Latest')),
                const PopupMenuItem(
                    value: 'most_liked', child: Text('Most Liked')),
                const PopupMenuItem(
                    value: 'top_voted', child: Text('Top Voted')),
              ],
            ),
          ],
        ),
        body: songs.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return SongCard(
                    title: song.title,
                    genres: song.genres,
                    coverUrl: song.originalUrl.isNotEmpty
                        ? song.originalUrl
                        : 'https://placehold.co/64x64',
                    onPlay: () {
                      // Play the original song audio
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => SizedBox(
                          height: 120,
                          child: Center(
                            child: Text(
                                'Audio player UI here (see SongDetailScreen for full version playback)'),
                          ),
                        ),
                      );
                    },
                    onDownload: () async {
                      // Download the song for offline use
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
                    onLike: () async {
                      final auth =
                          Provider.of<AuthProvider>(context, listen: false);
                      if (!auth.isLoggedIn) {
                        Navigator.pushNamed(context, '/login');
                      } else {
                        await songProvider.likeSong(song.id, auth.user!.uid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Liked!')),
                        );
                      }
                    },
                    onVote: () async {
                      final auth =
                          Provider.of<AuthProvider>(context, listen: false);
                      if (!auth.isLoggedIn) {
                        Navigator.pushNamed(context, '/login');
                      } else {
                        await songProvider.voteSong(song.id, auth.user!.uid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Voted!')),
                        );
                      }
                    },
                    onComment: () {
                      // Navigate to song detail/comments
                      Navigator.pushNamed(context, '/song-detail',
                          arguments: song);
                    },
                  );
                },
              ),
      ),
      // Downloads
      DownloadScreen(),
      // Search
      SearchScreen(),
      // Admin or Login
      if (isAdmin) const AdminDashboard() else const LoginScreen(),
    ];
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        isAdmin: isAdmin,
      ),
    );
  }
}
