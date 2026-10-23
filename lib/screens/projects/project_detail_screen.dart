import 'package:flutter/material.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Proje Detayı')),
    body: const Center(child: Text('Proje detayları burada geliştirilecek')),
  );
}
