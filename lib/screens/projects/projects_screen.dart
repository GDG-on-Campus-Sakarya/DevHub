import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../widgets/project_card.dart';
import '../applications/applications_screen.dart';
import '../applications/apply_dialog.dart';
import '../applications/incoming_applications_screen.dart';
import 'create_project_screen.dart';
import 'my_projects_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _service = ProjectService();
  late final Stream<List<Project>> _projects = _service.streamOpenProjects();

  String _query = '';
  String? _technology;
  String? _role;

  // Arama ve filtreler istemci tarafında uygulandı (tam metin arama MVP dışı)
  List<Project> _applyFilters(List<Project> projects) {
    final q = _query.trim().toLowerCase();
    return projects.where((p) {
      if (_technology != null && !p.technologies.contains(_technology)) return false;
      if (_role != null && !p.neededRoles.contains(_role)) return false;
      if (q.isEmpty) return true;
      return p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.technologies.any((t) => t.toLowerCase().contains(q)) ||
          p.neededRoles.any((r) => r.toLowerCase().contains(q));
    }).toList();
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // Sahibi, üyesi veya misafir olan kullanıcıya "Şimdi başvur" gösterilmedi
  VoidCallback? _applyAction(Project project) {
    final uid = _service.currentUserId;
    if (!_service.canContribute || project.isOwner(uid) || project.isMember(uid)) {
      return null;
    }
    return () => showApplyDialog(context, project);
  }

  @override
  Widget build(BuildContext context) {
    final canContribute = _service.canContribute;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projeleri Keşfet'),
        actions: [
          if (canContribute) ...[
            TextButton(onPressed: () => _push(const MyProjectsScreen()), child: const Text('Projelerim')),
            TextButton(onPressed: () => _push(const ApplicationsScreen()), child: const Text('Başvurularım')),
            TextButton(
                onPressed: () => _push(const IncomingApplicationsScreen()),
                child: const Text('Gelen Başvurular')),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<Project>>(
        stream: _projects,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: _Message(
                icon: Icons.error_outline,
                title: 'Projeler yüklenemedi',
                body: 'Bağlantını kontrol edip tekrar dene.',
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data!;
          final filtered = _applyFilters(all);
          final technologies = {for (final p in all) ...p.technologies}.toList()..sort();
          final roles = {for (final p in all) ...p.neededRoles}.toList()..sort();

          return LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1100 ? 3 : (width >= 720 ? 2 : 1);
            const gap = 16.0;
            final padding = width >= 720 ? 32.0 : 16.0;
            final cardWidth = (width - padding * 2 - gap * (columns - 1)) / columns;

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    onCreate: canContribute ? () => _push(const CreateProjectScreen()) : null,
                  ),
                  const SizedBox(height: 16),
                  _Filters(
                    technologies: technologies,
                    roles: roles,
                    technology: _technology,
                    role: _role,
                    onQuery: (v) => setState(() => _query = v),
                    onTechnology: (v) => setState(() => _technology = v),
                    onRole: (v) => setState(() => _role = v),
                  ),
                  const SizedBox(height: 16),
                  Text('${filtered.length} proje ekip arkadaşlarını bekliyor',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  if (all.isEmpty)
                    const _Message(
                      icon: Icons.folder_open_outlined,
                      title: 'Henüz açık proje yok',
                      body: 'İlk projeyi sen oluşturabilirsin.',
                    )
                  else if (filtered.isEmpty)
                    const _Message(
                      icon: Icons.search_off,
                      title: 'Sonuç bulunamadı',
                      body: 'Aramanı veya filtreleri değiştirmeyi dene.',
                    )
                  else
                    Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final project in filtered)
                          SizedBox(
                            width: cardWidth,
                            child: ProjectCard(project: project, onApply: _applyAction(project)),
                          ),
                      ],
                    ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onCreate});
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createButton = onCreate == null
        ? null
        : OutlinedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Proje oluştur'),
          );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          runSpacing: 16,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SANA UYGUN SONUÇLAR',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.primary, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text('Projeleri Keşfet',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'Heyecan verici öğrenci projelerini keşfet, yetenekli ekip arkadaşlarıyla tanış ve birlikte anlamlı işler üret.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (createButton != null) createButton,
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.technologies,
    required this.roles,
    required this.technology,
    required this.role,
    required this.onQuery,
    required this.onTechnology,
    required this.onRole,
  });

  final List<String> technologies;
  final List<String> roles;
  final String? technology;
  final String? role;
  final ValueChanged<String> onQuery;
  final ValueChanged<String?> onTechnology;
  final ValueChanged<String?> onRole;

  @override
  Widget build(BuildContext context) {
    Widget dropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
      return SizedBox(
        width: 200,
        child: DropdownButtonFormField<String?>(
          initialValue: value,
          isExpanded: true,
          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
          items: [
            DropdownMenuItem(value: null, child: Text(hint)),
            for (final item in items) DropdownMenuItem(value: item, child: Text(item)),
          ],
          onChanged: onChanged,
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 240, maxWidth: 520),
              child: TextField(
                onChanged: onQuery,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Proje, teknoloji veya yetenek ara...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            dropdown('Tüm teknolojiler', technology, technologies, onTechnology),
            dropdown('Tüm roller', role, roles, onRole),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(body, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
