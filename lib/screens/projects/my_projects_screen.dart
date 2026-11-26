import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../services/project_service.dart';
import 'project_detail_screen.dart';

class MyProjectsScreen extends StatelessWidget {
  const MyProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ProjectService();
    return Scaffold(
      appBar: AppBar(title: const Text('Projelerim')),
      body: StreamBuilder<List<Project>>(
        stream: service.streamMyProjects(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Projeler yüklenemedi: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = snapshot.data!;
          if (projects.isEmpty) {
            return const Center(child: Text('Henüz proje oluşturmadın.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final project = projects[index];
              final statusLabel = switch (project.effectiveStatus) {
                Project.statusOpen => 'Açık',
                Project.statusFull => 'Dolu',
                Project.statusCompleted => 'Tamamlandı',
                _ => 'Kapalı',
              };
              final memberText =
                  project.capacity != null && project.capacity! > 0
                      ? '${project.memberIds.length}/${project.capacity} üye'
                      : '${project.memberIds.length} üye';
              return Card(
                child: ListTile(
                  title: Text(project.title),
                  subtitle: Text(
                    [
                      if (project.category != null) project.category!,
                      memberText,
                      statusLabel,
                    ].join(' • '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProjectDetailScreen(projectId: project.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
