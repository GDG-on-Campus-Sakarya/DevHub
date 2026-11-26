import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../widgets/status_badge.dart';
import '../applications/apply_dialog.dart';
import '../applications/incoming_applications_screen.dart';
import 'create_project_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    this.service,
  });

  final String projectId;
  final ProjectService? service;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late final ProjectService _service = widget.service ?? ProjectService();
  bool _deleting = false;

  Future<void> _confirmDelete(Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Projeyi sil'),
        content: Text(
          '"${project.title}" projesini silmek istediğine emin misin? '
          'Bu projeye ait başvurular da kaldırılacak ve işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await _service.deleteProject(project);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proje silindi.')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proje detayı')),
      body: StreamBuilder<Project?>(
        stream: _service.streamProject(widget.projectId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Proje yüklenemedi: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = snapshot.data;
          if (p == null) {
            return const Center(child: Text('Proje bulunamadı veya silinmiş.'));
          }

          final isOwner = p.isOwner(_service.currentUserId);
          final isMember = p.isMember(_service.currentUserId);
          final teamLabel = p.capacity != null && p.capacity! > 0
              ? 'Ekip: ${p.memberIds.length} / ${p.capacity} üye'
              : 'Ekip: ${p.memberIds.length} üye';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          StatusBadge.project(p.effectiveStatus),
                          if (p.category != null)
                            Chip(
                              label: Text(p.category!),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        p.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Proje sahibi: ${p.ownerName.isEmpty ? 'DevHub üyesi' : p.ownerName}',
                      ),
                      const SizedBox(height: 18),
                      Text(p.description),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teknolojiler',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (p.technologies.isEmpty)
                        const Text('Belirtilmemiş')
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            for (final e in p.technologies) Chip(label: Text(e)),
                          ],
                        ),
                      const SizedBox(height: 18),
                      Text(
                        'Aranan roller',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (p.neededRoles.isEmpty)
                        const Text('Belirtilmemiş')
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            for (final e in p.neededRoles) Chip(label: Text(e)),
                          ],
                        ),
                      const SizedBox(height: 18),
                      Text(teamLabel),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (isOwner) ...[
                FilledButton.icon(
                  onPressed: _deleting
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  IncomingApplicationsScreen(projectId: p.id),
                            ),
                          ),
                  icon: const Icon(Icons.inbox_outlined),
                  label: const Text('Gelen başvuruları görüntüle'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _deleting
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateProjectScreen(project: p),
                            ),
                          ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Projeyi düzenle'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                    ),
                  ),
                  onPressed: _deleting ? null : () => _confirmDelete(p),
                  icon: _deleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  label: const Text('Projeyi sil'),
                ),
              ] else if (isMember)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Bu projenin ekip üyesisin.'),
                  ),
                )
              else if (!_service.canContribute)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Başvuru yapmak için e-posta hesabınla giriş yapmalısın.',
                    ),
                  ),
                )
              else if (p.isCompleted)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Bu proje tamamlanmıştır.'),
                  ),
                )
              else if (!p.isOpen)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Bu proje şu anda başvurulara kapalı.'),
                  ),
                )
              else if (p.isFull)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Bu projenin kontenjanı dolmuştur.'),
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: () => showApplyDialog(context, p),
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Projeye başvur'),
                ),
            ],
          );
        },
      ),
    );
  }
}
