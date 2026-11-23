import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

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
    home: const HomeScreen(),
  );
}
