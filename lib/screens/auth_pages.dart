import 'package:flutter/material.dart';
import '../data/app_scope.dart';
import '../widgets/app_ui.dart';
import '../widgets/page_background.dart';

class AuthPage extends StatefulWidget {
  final bool register;
  final bool reset;
  const AuthPage({super.key, this.register = false, this.reset = false});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true, _busy = false;
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    final store = AppScope.of(context);
    setState(() => _busy = true);
    try {
      if (widget.reset) {
        await store.resetPassword(_email.text.trim());
        if (mounted) {
          notice(
            context,
            'Se houver uma conta, você receberá as instruções por e-mail.',
          );
        }
      } else {
        if (widget.register) {
          await store.register(
            _name.text.trim(),
            _email.text.trim(),
            _password.text,
          );
        } else {
          await store.login(_email.text.trim(), _password.text);
        }
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
        }
      }
    } catch (e) {
      if (mounted) notice(context, errorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final demoRegister = widget.register && !store.cloudEnabled;
    final title = widget.reset
        ? 'Recuperar senha'
        : widget.register
        ? (demoRegister ? 'Criar perfil de teste' : 'Criar conta')
        : 'Entrar';
    return PageBackground(
      login: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: BackButton(
                  onPressed: _busy ? null : () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 10),
              const Brand(size: 80),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              if (!store.cloudEnabled)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Firebase ainda não configurado. Explore a demonstração com dados locais; ela não cria uma conta real.',
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              if (widget.register) ...[
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nome do tutor'),
                  validator: requiredText,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: emailValidator,
              ),
              if (!widget.reset && !demoRegister) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: _hide,
                  autofillHints: [
                    widget.register
                        ? AutofillHints.newPassword
                        : AutofillHints.password,
                  ],
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _hide ? 'Mostrar senha' : 'Ocultar senha',
                      onPressed: () => setState(() => _hide = !_hide),
                      icon: Icon(
                        _hide ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Informe a senha.'
                      : widget.register && v.length < 6
                      ? 'Use pelo menos 6 caracteres.'
                      : null,
                ),
                if (widget.register) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar senha',
                    ),
                    validator: (v) =>
                        v != _password.text ? 'As senhas não conferem.' : null,
                  ),
                ],
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: Text(_busy ? 'Aguarde…' : title),
              ),
              if (!widget.register && !widget.reset) ...[
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/recuperar-senha'),
                  child: const Text('Esqueceu a senha?'),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                  child: const Text('Criar conta'),
                ),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () async {
                          setState(() => _busy = true);
                          try {
                            await store.enterDemo();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/home',
                                (_) => false,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              notice(context, errorMessage(e));
                            }
                          } finally {
                            if (mounted) setState(() => _busy = false);
                          }
                        },
                  child: const Text('Explorar demonstração'),
                ),
              ],
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
