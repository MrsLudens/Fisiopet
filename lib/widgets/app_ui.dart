import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/app_scope.dart';

const ink = Color(0xFF344359);
const accent = Color(0xFF7653AD);
String dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
String timeLabel(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
String? requiredText(String? value) =>
    value == null || value.trim().isEmpty ? 'Preencha este campo.' : null;
String? emailValidator(String? value) =>
    value == null ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())
    ? 'Informe um e-mail válido.'
    : null;
String errorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'email-already-in-use' => 'Este e-mail já tem uma conta. Tente entrar.',
      'weak-password' => 'Escolha uma senha com pelo menos 6 caracteres.',
      'invalid-email' => 'Informe um e-mail válido.',
      'network-request-failed' => 'Confira sua conexão e tente novamente.',
      'too-many-requests' => 'Muitas tentativas. Aguarde e tente novamente.',
      'operation-not-allowed' =>
        'Ative o acesso por e-mail e senha no Firebase.',
      _ =>
        'Não foi possível entrar. Confira os dados e a configuração do Firebase.',
    };
  }
  if (error is StateError) return error.message.toString();
  return 'Não foi possível salvar ou carregar. Confira a conexão e tente novamente.';
}

void notice(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
Future<void> mutate(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (e) {
    if (context.mounted) notice(context, errorMessage(e));
  }
}

Future<bool> confirm(BuildContext context, String title, String text) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ??
    false;

class AppPage extends StatelessWidget {
  final String title;
  final Widget child;
  final int selected;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.selected = 0,
    this.actions,
    this.floatingActionButton,
  });
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        child: Column(
          children: [
            if (store.demo)
              Container(
                width: double.infinity,
                color: const Color(0xFFEDE6FA),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: const Text(
                  'Demonstração • dados salvos neste dispositivo',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: accent),
                ),
              ),
            if (store.writing) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) {
          const routes = ['/home', '/pets', '/agenda', '/perfil'];
          Navigator.pushNamedAndRemoveUntil(
            context,
            routes[i],
            (route) => false,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Pets',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 12),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  final String title, description;
  final String? button;
  final VoidCallback? onPressed;
  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.button,
    this.onPressed,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.pets, size: 48, color: accent),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(description, textAlign: TextAlign.center),
        if (button != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: FilledButton(onPressed: onPressed, child: Text(button!)),
          ),
      ],
    ),
  );
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFEDE6FA),
        child: Icon(icon, color: accent),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      isThreeLine: false,
      onTap: onTap,
      trailing:
          trailing ?? (onTap == null ? null : const Icon(Icons.chevron_right)),
    ),
  );
}

class PetPicker extends StatelessWidget {
  const PetPicker({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    if (store.pets.isEmpty) return const SizedBox.shrink();
    return DropdownButtonFormField<String>(
      key: ValueKey(store.selectedPet?.id),
      initialValue: store.selectedPet?.id,
      decoration: const InputDecoration(
        labelText: 'Pet selecionado',
        prefixIcon: Icon(Icons.pets),
      ),
      items: store.pets
          .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
          .toList(),
      onChanged: store.writing
          ? null
          : (id) {
              if (id != null) mutate(context, () => store.selectPet(id));
            },
    );
  }
}
