import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/google_sign_in_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            try {
              await authProvider.signInWithGoogle();
              Navigator.pop(context); // Go back after successful login
            } catch (e) {
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
