import 'package:flutter/material.dart';
import '../widgets/page_background.dart';

class LoginSelectPage extends StatelessWidget {
  const LoginSelectPage({super.key});

  @override
  Widget build(BuildContext context) => PageBackground(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Voltar',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          const SizedBox(height: 50),
          const Brand(size: 120),
          const SizedBox(height: 40),
          const Text(
            'Bem-vindo ao FisioPet!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF53617A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Vamos cuidar do seu melhor amigo?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF687588)),
          ),
          const SizedBox(height: 40),
          ActionButton(
            label: 'Entrar',
            color: purple,
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'Registrar',
            color: blue,
            onPressed: () => Navigator.pushNamed(context, '/cadastro'),
          ),
          const SizedBox(height: 60),
        ],
      ),
    ),
  );
}
