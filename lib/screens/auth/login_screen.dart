import 'package:flutter/material.dart';

import '../../navigation/app_routes.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.authService});
  final AuthService? authService;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  AuthService get _auth => widget.authService ?? AuthService();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.signIn(email: _email.text, password: _password.text);
      if (!mounted) return;
      // AuthGate authStateChanges üzerinden ana sayfaya geçer.
    } catch (e) {
      if (mounted) _message(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _message('Şifre sıfırlama bağlantısı için önce e-posta adresini yaz.', error: true);
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) _message('Şifre sıfırlama e-postası gönderildi.');
    } catch (e) {
      if (mounted) _message(e.toString(), error: true);
    }
  }

  void _message(String value, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: error ? Theme.of(context).colorScheme.error : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.hub_rounded, size: 46),
                        const SizedBox(height: 12),
                        Text('DevHub’a hoş geldin', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('Projeleri keşfetmek ve ekiplere katılmak için giriş yap.', textAlign: TextAlign.center),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(labelText: 'E-posta', prefixIcon: Icon(Icons.email_outlined)),
                          validator: (v) => v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()) ? 'Geçerli bir e-posta gir.' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(labelText: 'Şifre', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure)),),
                          validator: (v) => v == null || v.isEmpty ? 'Şifreni gir.' : null,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _loading ? null : _resetPassword, child: const Text('Şifremi unuttum')),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(onPressed: _loading ? null : _submit, child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Giriş yap')),
                        const SizedBox(height: 10),
                        TextButton(onPressed: _loading ? null : () => Navigator.pushNamed(context, AppRoutes.register), child: const Text('Hesabın yok mu? Kayıt ol')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
