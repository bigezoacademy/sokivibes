import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: GoogleSignInButton(
          onPressed: () async {
            print('Login button pressed');
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            try {
              print('Calling signInWithGoogle...');
              await authProvider.signInWithGoogle();
              print(
                  'signInWithGoogle completed. isLoggedIn: \\${authProvider.isLoggedIn}, isAdmin: \\${authProvider.isAdmin}');
              if (!context.mounted) return;
              if (!authProvider.isLoggedIn) {
                print('User not logged in after signInWithGoogle');
                // User cancelled or sign-in failed, do nothing or show a message
                return;
              }
              if (authProvider.isAdmin) {
                print('Redirecting to /admin-dashboard');
                Navigator.pushReplacementNamed(context, '/admin-dashboard');
              } else {
                print('Redirecting to /dashboard');
                Navigator.pushReplacementNamed(context, '/dashboard');
              }
            } catch (e, stack) {
              print('Google sign-in failed: \\${e.toString()}');
              print('Stack trace: \\${stack.toString()}');
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Google sign-in failed: \\${e.toString()}')),
              );
            }
          },
        ),
      ),
    );
  }
}
