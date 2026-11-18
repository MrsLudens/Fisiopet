import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/app_scope.dart';
import 'data/app_store.dart';
import 'data/firebase_config.dart';
import 'screens/start_page.dart';
import 'screens/login_select_page.dart';
import 'screens/login_page.dart';
import 'screens/auth_pages.dart';
import 'screens/home_page.dart';
import 'screens/pet_pages.dart';
import 'screens/agenda_page.dart';
import 'screens/activity_pages.dart';
import 'screens/progress_page.dart';
import 'screens/tips_page.dart';
import 'screens/profile_page.dart';
import 'widgets/app_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final cloud = await initializeFirebase();
    final prefs = await SharedPreferences.getInstance();
    runApp(FisioPetApp(store: AppStore(prefs, cloudEnabled: cloud)));
  } catch (_) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Não foi possível iniciar o FisioPet. Confira a configuração Firebase e o acesso ao armazenamento, depois abra novamente.',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FisioPetApp extends StatelessWidget {
  final AppStore store;
  const FisioPetApp({super.key, required this.store});
  @override
  Widget build(BuildContext context) => AppScope(
    store: store,
    child: MaterialApp(
      title: 'FisioPet',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: accent),
        scaffoldBackgroundColor: const Color(0xFFFAFAFD),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAFAFD),
          foregroundColor: ink,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final arg = settings.arguments;
        final id = arg is String ? arg : '';
        final public = [
          '/',
          '/login-select',
          '/login',
          '/cadastro',
          '/recuperar-senha',
        ];
        final Widget page;
        if (!public.contains(settings.name) && !store.signedIn) {
          page = const LoginPage();
        } else {
          page = switch (settings.name) {
            '/' => const StartPage(),
            '/login-select' => const LoginSelectPage(),
            '/login' => const LoginPage(),
            '/cadastro' => const AuthPage(register: true),
            '/recuperar-senha' => const AuthPage(reset: true),
            '/home' => const HomePage(),
            '/pets' => const PetsPage(),
            '/cadastrar-pet' => const PetFormPage(),
            '/editar-pet' => PetFormPage(id: id),
            '/detalhes-pet' => PetDetailsPage(id: id),
            '/exercicios' => const ActivitiesPage(),
            '/detalhes-exercicio' => ActivityDetailsPage(id: id),
            '/registrar-sessao' => SessionFormPage(activityId: id),
            '/agenda' => const AgendaPage(),
            '/novo-compromisso' => const AppointmentFormPage(),
            '/editar-compromisso' => AppointmentFormPage(id: id),
            '/progresso' => const ProgressPage(),
            '/dicas' => const TipsPage(),
            '/perfil' => const ProfilePage(),
            _ => const AppPage(
              title: 'Página não encontrada',
              child: EmptyState(
                title: 'Esta página não existe',
                description: 'Use a navegação para voltar ao início.',
              ),
            ),
          };
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => page,
        );
      },
    ),
  );
}
