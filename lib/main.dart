// lib/main.dart

import 'package:flui_app/app/core/theme/app_theme.dart'; 
import 'package:flui_app/app/presentation/screens/auth/onboarding_screen.dart'; 
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 


void main() async { // Transforme em async
  WidgetsFlutterBinding.ensureInitialized(); // Garante a inicialização
  await Firebase.initializeApp( // Inicializa o Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flui',
      debugShowCheckedModeBanner: false, 
      theme: AppTheme.mainTheme, 
      home: const OnboardingScreen(), 
    );
  }
}