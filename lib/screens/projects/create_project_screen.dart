import 'package:flutter/material.dart';

class CreateProjectScreen extends StatelessWidget {
  const CreateProjectScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Proje Oluştur')),
    body: const Center(child: Text('Proje formu burada geliştirilecek')),
  );
}
