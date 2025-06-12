import 'package:flutter/material.dart';
import '../../widgets/google_sign_in_button.dart';

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
          onPressed: () {
            // TODO: Implement Google sign-in logic here
          },
        ),
      ),
    );
  }
}
