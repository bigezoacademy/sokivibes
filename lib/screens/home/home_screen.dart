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
import '../auth/login_screen.dart';
import '../admin/admin_dashboard.dart';
import '../../models/song_model.dart';
import '../user_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _searchQuery = '';

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
    return FutureBuilder(
      future: songProvider.fetchSongs(),
      builder: (context, snapshot) {
        // Filter songs by search query
        final songs = _searchQuery.isEmpty
            ? songProvider.songs
            : songProvider.songs
                .where((song) =>
                    song.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    song.genres.any((g) =>
                        g.toLowerCase().contains(_searchQuery.toLowerCase())) ||
                    song.description
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();
        final List<Widget> _pages = [
          // Home
          Scaffold(
            appBar: AppBar(
              title: const Text('Soki-Vibes'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search songs...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ),
                ),
              ),
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
                    if (value == 'latest') {
                      songProvider.fetchSongs(sortBy: 'latest');
                    } else if (value == 'most_liked') {
                      songProvider.fetchSongs(sortBy: 'most_liked');
                    } else if (value == 'top_voted') {
                      songProvider.fetchSongs(sortBy: 'top_voted');
                    }
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
            body: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : songs.isEmpty
                    ? const Center(child: Text('No songs found.'))
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
                              final hasPermission = await PermissionService()
                                  .requestStoragePermission();
                              if (hasPermission) {
                                await StorageService()
                                    .downloadSong(song.originalUrl, song.title);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Downloaded ${song.title}')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Storage permission denied.')),
                                );
                              }
                            },
                            onLike: () async {
                              final auth = Provider.of<AuthProvider>(context,
                                  listen: false);
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
                            onVote: () async {
                              final auth = Provider.of<AuthProvider>(context,
                                  listen: false);
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
                            onComment: () {
                              Navigator.pushNamed(context, '/song-detail',
                                  arguments: song);
                            },
                          );
                        },
                      ),
          ),
          // Library (liked songs)
          UserDashboard(),
          // Downloads
          DownloadScreen(),
          // Upload (for admin) or Downloads (for users)
          isAdmin ? AdminDashboard() : DownloadScreen(),
          // Admin or Login
          if (isAdmin) const AdminDashboard() else const LoginScreen(),
        ];
        return Scaffold(
          body: _pages[_currentIndex],
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            isAdmin: isAdmin,
          ),
        );
      },
    );
  }
}
