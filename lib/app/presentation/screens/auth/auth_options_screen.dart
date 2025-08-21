import 'package:flutter/material.dart';
import 'package:flui_app/app/presentation/screens/auth/login_screen.dart';
import 'package:flui_app/app/presentation/screens/auth/signup_screen.dart';

class AuthOptionsScreen extends StatelessWidget {
  const AuthOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Adicionamos um AppBar para ter o botão de "voltar" automaticamente
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagem do Capi para manter a identidade
              Image.asset(
                'assets/images/capi-inicio.png',
                height: 120,
              ),
              const SizedBox(height: 48),

              // Botão de Entrar
              ElevatedButton(
                onPressed: () {
                  // Navega para a tela de Login que já criamos
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('ENTRAR'),
              ),

              const SizedBox(height: 16),

              // Botão de Cadastrar
              TextButton(
                onPressed: () {
                  // Navega para a tela de Cadastro que já criamos
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                child: const Text('CADASTRAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}