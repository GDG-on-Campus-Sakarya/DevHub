import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

/// Firebase oturum durumuna göre kullanıcıyı otomatik yönlendiren geçit widget'ı.
class AuthGate extends StatelessWidget {
  final AuthService? authService;

  const AuthGate({super.key, this.authService});

  @override
  Widget build(BuildContext context) {
    final service = authService ?? AuthService();

    // Oturum akışı StreamBuilder ile gerçek zamanlı dinlendi
    return StreamBuilder<User?>(
      stream: service.authStateChanges,
      builder: (context, snapshot) {
        // Oturum durumu kontrol edilirken yükleniyor çarkı gösterildi
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Oturum durumu kontrol edilirken bir hata oluştu.'),
            ),
          );
        }

        // Aktif oturum varsa ana sayfa, yoksa giriş ekranı açıldı
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
