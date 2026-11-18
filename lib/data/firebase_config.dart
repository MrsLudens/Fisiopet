import 'package:firebase_core/firebase_core.dart';

// Passe --dart-define-from-file=firebase.config.json após preencher o arquivo.
Future<bool> initializeFirebase() async {
  const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  const appId = String.fromEnvironment('FIREBASE_APP_ID');
  const sender = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  const project = String.fromEnvironment('FIREBASE_PROJECT_ID');
  if (apiKey.isEmpty && appId.isEmpty && project.isEmpty) return false;
  if ([apiKey, appId, sender, project].any((s) => s.isEmpty)) {
    throw StateError(
      'Configuração Firebase incompleta. Confira firebase.config.json.',
    );
  }
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: sender,
      projectId: project,
      authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
      storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    ),
  );
  return true;
}
