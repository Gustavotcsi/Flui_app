import 'package:flutter/material.dart';
import 'package:flui_app/app/presentation/screens/auth/auth_options_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/capi-inicio.png', width: 150),
            const SizedBox(height: 40),
            const Text(
              'Bem-vindo ao Flui!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Seu parceiro para conquistar seus sonhos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthOptionsScreen()),
                );
              },
              child: const Text('COMEÇAR'),
            ),
          ],
        ),
      ),
    );
  }
}
