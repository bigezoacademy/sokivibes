import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : GoogleSignInButton(
                  onPressed: () async {
                    setState(() => _loading = true);
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    try {
                      await authProvider.signInWithGoogle();
                      if (!context.mounted) return;
                      // No navigation here! Let HomeScreen react to auth state
                      if (!authProvider.isLoggedIn) {
                        setState(() => _loading = false);
                        return;
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Google sign-in failed: \\${e.toString()}')),
                      );
                    } finally {
                      if (mounted) setState(() => _loading = false);
                    }
                  },
                ),
        ),
      ),
      // Removed BottomNavBar here to prevent double navbars when used as a tab
    );
  }
}
