import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'dart:js' as js;

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const SokiVibesAppWithTheme(),
      ),
    );
  } catch (e, stack) {
    js.context.callMethod('console', [
      'error',
      'Firebase/App initialization error:',
      e.toString(),
      stack.toString(),
    ]);
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('App failed to start. Check browser console for errors.'),
        ),
      ),
    ));
  }
}

class SokiVibesAppWithTheme extends StatelessWidget {
  const SokiVibesAppWithTheme({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      home: const SokiVibesApp(),
    );
  }
}
