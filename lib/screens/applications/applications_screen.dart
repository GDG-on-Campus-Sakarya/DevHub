import 'package:flutter/material.dart';
import '../../models/project_application.dart';
import '../../services/project_service.dart';
import '../../widgets/status_badge.dart';

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final service = ProjectService();
    return Scaffold(appBar: AppBar(title: const Text('Başvurularım')), body: StreamBuilder<List<ProjectApplication>>(
      stream: service.streamMyApplications(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Başvurular yüklenemedi: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        if (list.isEmpty) return const Center(child: Text('Henüz bir projeye başvurmadın.'));
        return ListView.separated(padding: const EdgeInsets.all(16), itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (context, i) {
          final a = list[i];
          return Card(child: ListTile(title: Text(a.projectTitle.isEmpty ? 'Proje başvurusu' : a.projectTitle), subtitle: Text(a.message, maxLines: 3, overflow: TextOverflow.ellipsis), trailing: StatusBadge.application(a.status)));
        });
      },
    ));
  }
}
