import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../widgets/status_badge.dart';
import '../applications/apply_dialog.dart';
import '../applications/incoming_applications_screen.dart';
import 'create_project_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context) {
    final service = ProjectService();
    return Scaffold(appBar: AppBar(title: const Text('Proje detayı')), body: StreamBuilder<Project?>(
      stream: service.streamProject(projectId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Proje yüklenemedi: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final p = snapshot.data;
        if (p == null) return const Center(child: Text('Proje bulunamadı.'));
        final isOwner = p.isOwner(service.currentUserId);
        final isMember = p.isMember(service.currentUserId);
        return ListView(padding: const EdgeInsets.all(20), children: [
          Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            StatusBadge.project(p.status), const SizedBox(height: 14), Text(p.title, style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 8), Text('Proje sahibi: ${p.ownerName.isEmpty ? 'DevHub üyesi' : p.ownerName}'), const SizedBox(height: 18), Text(p.description),
          ]))),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Teknolojiler', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), Wrap(spacing: 8, children: [for(final e in p.technologies) Chip(label: Text(e))]),
            const SizedBox(height: 18), Text('Aranan roller', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), Wrap(spacing: 8, children: [for(final e in p.neededRoles) Chip(label: Text(e))]),
            const SizedBox(height: 18), Text('Ekip: ${p.memberIds.length} üye'),
          ]))),
          const SizedBox(height: 12),
          if (isOwner) ...[
            FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IncomingApplicationsScreen(projectId: p.id))), icon: const Icon(Icons.inbox_outlined), label: const Text('Gelen başvuruları görüntüle')),
            const SizedBox(height: 8), OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateProjectScreen(project: p))), icon: const Icon(Icons.edit_outlined), label: const Text('Projeyi düzenle')),
          ] else if (isMember) const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Bu projenin ekip üyesisin.')))
          else if (!service.canContribute) const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Başvuru yapmak için e-posta hesabınla giriş yapmalısın.')))
          else if (!p.isOpen) const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Bu proje şu anda başvurulara kapalı.')))
          else FilledButton.icon(onPressed: () => showApplyDialog(context, p), icon: const Icon(Icons.send_outlined), label: const Text('Projeye başvur')),
        ]);
      },
    ));
  }
}
