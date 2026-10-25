import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Formun geçerlilik durumunu tek noktadan yönetmek için anahtar tanımlandı
  final _formKey = GlobalKey<FormState>();

  // Kullanıcı girdilerini okumak için kontrolcüler oluşturuldu
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Bellek sızıntısını önlemek için kontrolcüler bellekten temizlendi
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Giriş işlemi başlatıldı ve hata durumları yakalandı
  Future<void> _handleLogin() async {
    // Formdaki tüm validator kuralları tetiklendi
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Başarılı girişte kullanıcı bilgilendirildi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giriş başarılı!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Hata durumunda kullanıcıya uyarı gösterildi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Google ile giriş işlemi tetiklendi
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google ile giriş başarılı!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // GitHub ile giriş işlemi tetiklendi
  Future<void> _handleGithubLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGithub();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GitHub ile giriş başarılı!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Microsoft ile giriş işlemi tetiklendi
  Future<void> _handleMicrosoftLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithMicrosoft();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microsoft ile giriş başarılı!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // LinkedIn ile giriş işlemi tetiklendi
  Future<void> _handleLinkedinLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithLinkedin();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('LinkedIn ile giriş başarılı!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            // Web ve masaüstünde aşırı genişlemeyi önlemek için sınırlandırıldı
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Color(0xFF3157D5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'DevHub Giriş',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hesabınıza giriş yaparak projelere katılın',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    // E-posta alanı ve doğrulaması
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen e-posta adresinizi giriniz.';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value.trim())) {
                          return 'Lütfen geçerli bir e-posta adresi giriniz.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Şifre alanı ve görünürlük butonu
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen şifrenizi giriniz.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Giriş butonu veya yükleniyor göstergesi
                    FilledButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Giriş Yap', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 20),

                    // Sosyal giriş ayracı
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'veya',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Google ile giriş butonu
                    OutlinedButton.icon(
                      icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                      label: const Text('Google ile Giriş Yap'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isLoading ? null : _handleGoogleLogin,
                    ),
                    const SizedBox(height: 12),

                    // GitHub ile giriş butonu
                    OutlinedButton.icon(
                      icon: const Icon(Icons.code, size: 22, color: Colors.black87),
                      label: const Text('GitHub ile Giriş Yap'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isLoading ? null : _handleGithubLogin,
                    ),
                    const SizedBox(height: 12),

                    // Microsoft ile giriş butonu
                    OutlinedButton.icon(
                      icon: const Icon(Icons.window, size: 22, color: Color(0xFF00A4EF)),
                      label: const Text('Microsoft ile Giriş Yap'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isLoading ? null : _handleMicrosoftLogin,
                    ),
                    const SizedBox(height: 12),

                    // LinkedIn ile giriş butonu
                    OutlinedButton.icon(
                      icon: const Icon(Icons.business, size: 22, color: Color(0xFF0A66C2)),
                      label: const Text('LinkedIn ile Giriş Yap'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isLoading ? null : _handleLinkedinLogin,
                    ),
                    const SizedBox(height: 16),

                    // Kayıt ekranına yönlendirme bağlantısı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Hesabınız yok mu?'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text('Kayıt Ol'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
