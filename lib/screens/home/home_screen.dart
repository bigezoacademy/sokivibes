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
import '../admin/admin_dashboard.dart';
import '../admin/analytics_screen.dart';
import '../../models/song_model.dart';
import '../user_dashboard.dart';
import '../song/song_covers_page.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';

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
    final isLoggedIn = authProvider.isLoggedIn;
    final songProvider = Provider.of<SongProvider>(context);

    List<Widget> _pages;
    if (isAdmin) {
      // Admin: Home, Library, Upload, Analytics
      _pages = [
        HomeTabWidget(),
        UserDashboard(),
        AdminDashboard(), // Upload form
        AnalyticsScreen(), // New analytics page
      ];
    } else if (isLoggedIn) {
      // Logged-in user: Home, Library, Downloads, Profile
      _pages = [
        HomeTabWidget(),
        UserDashboard(),
        DownloadScreen(),
        ProfileScreen(),
      ];
    } else {
      // Not logged in: Home, Library, Downloads, Login
      _pages = [
        HomeTabWidget(),
        UserDashboard(),
        DownloadScreen(),
        LoginScreen(
            // Remove showBottomNav, currentIndex, onTab props
            ),
      ];
    }

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
  }
}

class HomeTabWidget extends StatefulWidget {
  @override
  _HomeTabWidgetState createState() => _HomeTabWidgetState();
}

class _HomeTabWidgetState extends State<HomeTabWidget> {
  late Future<void> _fetchSongsFuture;

  @override
  void initState() {
    super.initState();
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    _fetchSongsFuture = songProvider.fetchSongs();
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    final _searchQuery = homeState?._searchQuery ?? '';
    final songs = _searchQuery.isEmpty
        ? songProvider.songs
        : songProvider.songs
            .where((song) =>
                song.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                song.genres.any((g) =>
                    g.toLowerCase().contains(_searchQuery.toLowerCase())) ||
                song.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList();
    return FutureBuilder(
      future: _fetchSongsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(
                  'Failed to load songs.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                // The error text below is not const because it depends on snapshot.error
              ],
            ),
          );
        } else if (songs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.music_off, color: Colors.grey, size: 48),
                SizedBox(height: 16),
                Text(
                  'No songs found.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Try uploading a song or check your connection.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Soki-Vibes'),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _HomeSearchField(),
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
                  setState(() {
                    final songProvider =
                        Provider.of<SongProvider>(context, listen: false);
                    if (value == 'latest') {
                      _fetchSongsFuture =
                          songProvider.fetchSongs(sortBy: 'latest');
                    } else if (value == 'most_liked') {
                      _fetchSongsFuture =
                          songProvider.fetchSongs(sortBy: 'most_liked');
                    } else if (value == 'top_voted') {
                      _fetchSongsFuture =
                          songProvider.fetchSongs(sortBy: 'top_voted');
                    }
                  });
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'latest', child: Text('Latest')),
                  PopupMenuItem(value: 'most_liked', child: Text('Most Liked')),
                  PopupMenuItem(value: 'top_voted', child: Text('Top Voted')),
                ],
              ),
            ],
          ),
          body: songs.isEmpty
              ? const Center(child: Text('No songs found.'))
              : ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16, top: 8),
                          child: Text(
                            'Original',
                            style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SongCard(
                          title: song.title,
                          genres: song.genres,
                          coverUrl: song.originalUrl.isNotEmpty
                              ? song.originalUrl
                              : 'https://placehold.co/64x64',
                          onPlay: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => const SizedBox(
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
                                        Text('Downloaded \\${song.title}')),
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
                          onCovers: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SongCoversPage(song: song),
                              ),
                            );
                          },
                        ),
                        if (song.versions.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 24, top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.library_music,
                                    color: Colors.pink.shade200, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '\\${song.versions.length - 1} cover(s) available',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.pink.shade200),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            SongCoversPage(song: song),
                                      ),
                                    );
                                  },
                                  child: const Text('View Covers'),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.pink),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }
}

class _HomeSearchField extends StatelessWidget {
  const _HomeSearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search songs...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      onChanged: (query) {
        final homeState = context.findAncestorStateOfType<_HomeScreenState>();
        if (homeState != null) {
          // ignore: invalid_use_of_protected_member
          homeState.setState(() {
            homeState._searchQuery = query;
          });
        }
      },
    );
  }
}
