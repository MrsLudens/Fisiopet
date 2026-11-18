import 'package:flutter/material.dart';
import '../data/app_scope.dart';
import '../widgets/app_ui.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _phone = TextEditingController();
  bool _loaded = false, _busy = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final store = AppScope.of(context);
    _name.text = store.name;
    _phone.text = store.phone;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return AppPage(
      title: 'Perfil do tutor',
      selected: 3,
      child: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFEDE6FA),
                child: Icon(Icons.person, size: 48, color: accent),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: requiredText,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: store.email,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone (opcional)',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy
                  ? null
                  : () async {
                      if (!_form.currentState!.validate()) return;
                      setState(() => _busy = true);
                      try {
                        await store.saveProfile(
                          _name.text.trim(),
                          _phone.text.trim(),
                        );
                        if (context.mounted) {
                          notice(context, 'Perfil atualizado.');
                        }
                      } catch (e) {
                        if (context.mounted) notice(context, errorMessage(e));
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
              child: Text(_busy ? 'Salvando…' : 'Salvar perfil'),
            ),
            const SectionTitle('Sobre seus dados'),
            Text(
              store.demo
                  ? 'Você está usando um perfil de demonstração. Os dados ficam neste navegador ou dispositivo e podem ser apagados ao limpar os dados do aplicativo.'
                  : 'Seus dados estão vinculados à sua conta Firebase. As gravações requerem conexão. Evite editar o mesmo perfil simultaneamente em dispositivos diferentes.',
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
              onPressed: store.writing || _busy
                  ? null
                  : () async {
                      try {
                        await store.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login-select',
                            (_) => false,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) notice(context, errorMessage(e));
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
