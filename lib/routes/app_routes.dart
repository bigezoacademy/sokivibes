import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/downloads/download_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/auth/login_screen.dart';
import '../screens/contact/request_service_screen.dart';
import '../screens/song/song_detail_screen.dart';
// Add other imports as screens are created

class AppRoutes {
  static const String home = '/';
  static const String downloads = '/downloads';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String admin = '/admin';
  static const String login = '/login';
  static const String requestService = '/request-service';
  static const String songDetail = '/song-detail';
  // Add other route names here

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const HomeScreen(),
        downloads: (context) => const DownloadScreen(),
        search: (context) => const SearchScreen(),
        profile: (context) => const ProfileScreen(),
        admin: (context) => const AdminDashboard(),
        login: (context) => const LoginScreen(),
        requestService: (context) => const RequestServiceScreen(),
        songDetail: (context) => const SongDetailScreen(),
        // Add other routes here
      };
}
