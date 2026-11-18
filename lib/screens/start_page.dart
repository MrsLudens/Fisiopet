import 'package:flutter/material.dart';
import '../widgets/page_background.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) => PageBackground(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Brand(size: 125),
            const SizedBox(height: 20),
            const Text(
              'Cuidado e movimento para o seu pet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF687588), fontSize: 16),
            ),
            const SizedBox(height: 48),
            ActionButton(
              label: 'Começar',
              color: purple,
              onPressed: () => Navigator.pushNamed(context, '/login-select'),
            ),
          ],
        ),
      ),
    ),
  );
}
