import 'package:flutter/material.dart';
import 'screens/auth/auth_gate.dart';

class DevHubApp extends StatelessWidget {
  const DevHubApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'DevHub',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3157D5)),
      useMaterial3: true,
    ),
    // Uygulama girişi oturum kontrol kapısına (AuthGate) bağlandı
    home: const AuthGate(),
  );
}
