import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/themes.dart';
import 'providers/auth_provider.dart';
import 'providers/song_provider.dart';
import 'providers/comment_provider.dart';
import 'routes/app_routes.dart';

class ThemeModeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class SokiVibesApp extends StatelessWidget {
  const SokiVibesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SongProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeModeProvider()),
      ],
      child: Consumer<ThemeModeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Soki-Vibes',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: AppRoutes.home,
          routes: AppRoutes.routes,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
