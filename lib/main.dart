import 'package:flutter/material.dart';
import 'screens/start_page.dart';
import 'screens/login_select_page.dart';
import 'screens/login_page.dart';

void main() => runApp(const FisioPetApp());

class FisioPetApp extends StatelessWidget {
  const FisioPetApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FisioPet',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA888D6)),
      scaffoldBackgroundColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    ),
    initialRoute: '/',
    routes: {
      '/': (_) => const StartPage(),
      '/login-select': (_) => const LoginSelectPage(),
      '/login': (_) => const LoginPage(),
    },
  );
}
