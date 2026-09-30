import 'package:flutter/material.dart';
import '../widgets/page_background.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;

  void _message(String title, String message) => showDialog<void>(
    context: context, builder: (context) => AlertDialog(
      title: Text(title), content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));

  @override
  Widget build(BuildContext context) => PageBackground(login: true,
    child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: IconButton(
            tooltip: 'Voltar', onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF40536B)))),
          const SizedBox(height: 24),
          const Brand(size: 90),
          const SizedBox(height: 42),
          const Text('Entrar', textAlign: TextAlign.center, style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF53617A))),
          const SizedBox(height: 24),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline)),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Informe seu e-mail.';
              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                return 'Informe um e-mail válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          TextFormField(
            obscureText: _hidePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(labelText: 'Senha', prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(tooltip: _hidePassword ? 'Mostrar senha' : 'Ocultar senha',
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                icon: Icon(_hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined))),
            validator: (value) => value == null || value.isEmpty ? 'Informe sua senha.' : null,
          ),
          Align(alignment: Alignment.centerRight, child: TextButton(
            onPressed: () => _message('Recuperar senha',
              'A recuperação de senha será conectada ao serviço de autenticação na próxima etapa.'),
            child: const Text('Esqueceu a senha?'))),
          const SizedBox(height: 12),
          ActionButton(label: 'Entrar', color: purple, onPressed: _submit),
          const SizedBox(height: 24),
          const Text('Feito com carinho para o seu pet', textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF687588))),
          const SizedBox(height: 8),
          const Icon(Icons.favorite, color: purple, size: 20),
          const SizedBox(height: 70),
        ]))),
  );

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _message('Protótipo de login',
        'Os campos foram validados. A autenticação e a tela inicial serão implementadas na próxima etapa.');
    }
  }
}
