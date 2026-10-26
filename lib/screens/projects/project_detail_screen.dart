import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../models/project_application.dart';
import '../../services/project_service.dart';
import '../../widgets/project_card.dart';
import '../../widgets/status_badge.dart';
import '../applications/apply_dialog.dart';
import '../applications/incoming_applications_screen.dart';
import 'create_project_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId});
  final String projectId;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _service = ProjectService();
  late final Stream<Project?> _project = _service.streamProject(widget.projectId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proje Detayı')),
      body: StreamBuilder<Project?>(
        stream: _project,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Proje yüklenemedi. Lütfen tekrar dene.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final project = snapshot.data;
          if (project == null) {
            return const Center(child: Text('Bu proje bulunamadı. Silinmiş olabilir.'));
          }

          return LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final main = _MainColumn(project: project);
            final side = _SideColumn(project: project, service: _service);

            return SingleChildScrollView(
              padding: EdgeInsets.all(wide ? 32 : 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Hero(project: project, wide: wide),
                      const SizedBox(height: 16),
                      _Stats(project: project),
                      const SizedBox(height: 16),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: main),
                            const SizedBox(width: 16),
                            Expanded(child: side),
                          ],
                        )
                      else ...[
                        side,
                        const SizedBox(height: 16),
                        main,
                      ],
                    ],
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.title});
  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.project, required this.wide});
  final Project project;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusBadge.project(project.status),
        const SizedBox(height: 12),
        Text(project.title,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
        if (project.ownerName.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Proje sahibi: ${project.ownerName}',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ],
    );

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: wide
          ? Row(
              children: [
                Expanded(child: Padding(padding: const EdgeInsets.all(28), child: info)),
                SizedBox(width: 360, child: ProjectCover(project: project, height: 180)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProjectCover(project: project, height: 120),
                Padding(padding: const EdgeInsets.all(20), child: info),
              ],
            ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final stats = {
      'Ekip büyüklüğü': '${project.memberIds.length} üye',
      'Açık roller': '${project.neededRoles.length}',
      'Ana teknoloji': project.technologies.isEmpty ? '—' : project.technologies.first,
    };
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Wrap(
        children: [
          for (final entry in stats.entries)
            SizedBox(
              width: 240,
              child: ListTile(
                dense: true,
                title: Text(entry.key, style: Theme.of(context).textTheme.bodySmall),
                trailing: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}

class _MainColumn extends StatelessWidget {
  const _MainColumn({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          title: 'Proje hakkında',
          child: Text(project.description,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
        ),
        _Panel(
          title: 'Açık roller',
          child: project.neededRoles.isEmpty
              ? const Text('Şu anda belirtilmiş açık rol yok.')
              : Column(
                  children: [
                    for (final role in project.neededRoles)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(Icons.group_outlined, color: theme.colorScheme.primary),
                        ),
                        title: Text(role, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
        ),
        _Panel(
          title: 'Teknolojiler',
          child: project.technologies.isEmpty
              ? const Text('Teknoloji belirtilmemiş.')
              : TagWrap(tags: project.technologies),
        ),
      ],
    );
  }
}

/// Kullanıcının rolüne göre değişen eylem kartı.
class _SideColumn extends StatelessWidget {
  const _SideColumn({required this.project, required this.service});
  final Project project;
  final ProjectService service;

  @override
  Widget build(BuildContext context) {
    final uid = service.currentUserId;

    if (project.isOwner(uid)) {
      return _Panel(
        title: 'Projeni yönet',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Bu projenin sahibisin. Bilgileri güncelleyebilir ve gelen başvuruları değerlendirebilirsin.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.inbox_outlined),
              label: const Text('Gelen başvuruları gör'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => IncomingApplicationsScreen(projectId: project.id)),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Projeyi düzenle'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateProjectScreen(project: project)),
              ),
            ),
          ],
        ),
      );
    }

    if (project.isMember(uid)) {
      return const _Panel(title: 'Ekiptesin', child: Text('Bu projenin bir üyesisin.'));
    }

    if (!service.canContribute) {
      return const _Panel(
        title: 'Katkı sunmaya hazır mısın?',
        child: Text('Başvurmak için misafir olarak değil, hesabınla giriş yapmalısın.'),
      );
    }

    // Kullanıcının bu projeye önceki başvurusu dinlendi; varsa durumu gösterildi
    return StreamBuilder<ProjectApplication?>(
      stream: service.streamMyApplicationFor(project.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Panel(child: Center(child: CircularProgressIndicator()));
        }
        final application = snapshot.data;
        if (application != null) {
          return _Panel(
            title: 'Başvurun',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge.application(application.status),
                const SizedBox(height: 12),
                Text('"${application.message}"'),
              ],
            ),
          );
        }
        if (!project.isOpen) {
          return const _Panel(
            title: 'Başvurulara kapalı',
            child: Text('Proje sahibi şu anda yeni başvuru kabul etmiyor.'),
          );
        }
        return _Panel(
          title: 'Katkı sunmaya hazır mısın?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Kendini ekibe tanıt ve yeteneklerinin projeyi nasıl ileri taşıyabileceğini anlat.'),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Katılmak için başvur'),
                onPressed: () => showApplyDialog(context, project),
              ),
            ],
          ),
        );
      },
    );
  }
}
