import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.authService});
  final AuthService? authService;
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  AuthService get _auth => widget.authService ?? AuthService();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _password.dispose(); _confirm.dispose(); super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.signUp(name: _name.text, email: _email.text, password: _password.text);
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).colorScheme.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Hesap oluştur')),
    body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Card(child: Padding(padding: const EdgeInsets.all(28), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('DevHub’a katıl', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8), const Text('Profilini oluştur ve öğrenci projelerinde yerini al.'), const SizedBox(height: 24),
        TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Ad soyad'), textCapitalization: TextCapitalization.words, validator: (v) => v == null || v.trim().length < 2 ? 'Ad soyad en az 2 karakter olmalı.' : null),
        const SizedBox(height: 14),
        TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-posta'), validator: (v) => v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()) ? 'Geçerli bir e-posta gir.' : null),
        const SizedBox(height: 14),
        TextFormField(controller: _password, obscureText: _obscure, decoration: InputDecoration(labelText: 'Şifre', suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined))), validator: (v) => v == null || v.length < 6 ? 'Şifre en az 6 karakter olmalı.' : null),
        const SizedBox(height: 14),
        TextFormField(controller: _confirm, obscureText: true, decoration: const InputDecoration(labelText: 'Şifre tekrar'), validator: (v) => v != _password.text ? 'Şifreler eşleşmiyor.' : null),
        const SizedBox(height: 22),
        FilledButton(onPressed: _loading ? null : _submit, child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Kayıt ol')),
      ]))))),
    )),
  );
}
