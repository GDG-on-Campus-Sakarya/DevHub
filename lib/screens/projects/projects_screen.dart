import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../widgets/project_card.dart';
import '../applications/applications_screen.dart';
import '../applications/incoming_applications_screen.dart';
import 'create_project_screen.dart';
import 'my_projects_screen.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key, this.service});

  final ProjectService? service;

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late final ProjectService _service = widget.service ?? ProjectService();
  late final Stream<List<Project>> _projects = _service.streamAllProjects();
  final _query = TextEditingController();

  String? _selectedCategory;
  String? _selectedTechnology;
  String? _selectedStatus;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _query.text.trim().isNotEmpty ||
      _selectedCategory != null ||
      _selectedTechnology != null ||
      _selectedStatus != null;

  void _clearFilters() {
    setState(() {
      _query.clear();
      _selectedCategory = null;
      _selectedTechnology = null;
      _selectedStatus = null;
    });
  }

  List<Project> _filterProjects(List<Project> allProjects) {
    final q = _query.text.trim().toLowerCase();
    return allProjects.where((p) {
      if (q.isNotEmpty) {
        final matchesText = p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            (p.category?.toLowerCase().contains(q) ?? false) ||
            p.technologies.any((e) => e.toLowerCase().contains(q)) ||
            p.neededRoles.any((e) => e.toLowerCase().contains(q));
        if (!matchesText) return false;
      }

      if (_selectedCategory != null && p.category != _selectedCategory) {
        return false;
      }

      if (_selectedTechnology != null &&
          !p.technologies.any(
            (t) => t.toLowerCase() == _selectedTechnology!.toLowerCase(),
          )) {
        return false;
      }

      if (_selectedStatus != null && p.effectiveStatus != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  List<String> _availableTechnologies(List<Project> allProjects) {
    final set = <String>{};
    for (final p in allProjects) {
      for (final tech in p.technologies) {
        final trimmed = tech.trim();
        if (trimmed.isNotEmpty) set.add(trimmed);
      }
    }
    return set.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projeleri keşfet'),
        actions: [
          if (_service.canContribute)
            PopupMenuButton<String>(
              onSelected: (v) {
                final Widget page = switch (v) {
                  'mine' => const MyProjectsScreen(),
                  'sent' => const ApplicationsScreen(),
                  _ => const IncomingApplicationsScreen(),
                };
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                );
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'mine', child: Text('Projelerim')),
                PopupMenuItem(value: 'sent', child: Text('Başvurularım')),
                PopupMenuItem(
                  value: 'incoming',
                  child: Text('Gelen başvurular'),
                ),
              ],
            ),
          if (_service.canContribute)
            IconButton(
              tooltip: 'Proje oluştur',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
              ),
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: StreamBuilder<List<Project>>(
        stream: _projects,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 42),
                    const SizedBox(height: 12),
                    Text(
                      'Projeler yüklenemedi: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allProjects = snapshot.data!;
          final projects = _filterProjects(allProjects);
          final availableTechnologies = _availableTechnologies(allProjects);

          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 1000
                  ? 3
                  : constraints.maxWidth > 650
                      ? 2
                      : 1;
              const gap = 16.0;
              final padding = constraints.maxWidth > 650 ? 28.0 : 16.0;
              final width =
                  (constraints.maxWidth - padding * 2 - gap * (columns - 1)) /
                      columns;

              return ListView(
                padding: EdgeInsets.all(padding),
                children: [
                  Text(
                    'Projeni paylaş, ekibini bul.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Öğrenci projelerini keşfet; kategori, teknoloji veya duruma göre filtrele.',
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _query,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText:
                          'Proje adı, açıklama, teknoloji veya kategori ara',
                      suffixIcon: _query.text.isNotEmpty
                          ? IconButton(
                              tooltip: 'Aramayı temizle',
                              onPressed: () => setState(() => _query.clear()),
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 205,
                        child: DropdownButtonFormField<String?>(
                          isExpanded: true,
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Tüm kategoriler',
                                  overflow: TextOverflow.ellipsis),
                            ),
                            for (final cat in Project.categories)
                              DropdownMenuItem<String?>(
                                value: cat,
                                child:
                                    Text(cat, overflow: TextOverflow.ellipsis),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedCategory = value),
                        ),
                      ),
                      SizedBox(
                        width: 195,
                        child: DropdownButtonFormField<String?>(
                          isExpanded: true,
                          initialValue: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Durum',
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Tüm durumlar',
                                  overflow: TextOverflow.ellipsis),
                            ),
                            DropdownMenuItem<String?>(
                              value: Project.statusOpen,
                              child: Text('Açık'),
                            ),
                            DropdownMenuItem<String?>(
                              value: Project.statusFull,
                              child: Text('Dolu'),
                            ),
                            DropdownMenuItem<String?>(
                              value: Project.statusClosed,
                              child: Text('Kapalı'),
                            ),
                            DropdownMenuItem<String?>(
                              value: Project.statusCompleted,
                              child: Text('Tamamlandı'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedStatus = value),
                        ),
                      ),
                      if (availableTechnologies.isNotEmpty)
                        SizedBox(
                          width: 205,
                          child: DropdownButtonFormField<String?>(
                            isExpanded: true,
                            initialValue: _selectedTechnology,
                            decoration: const InputDecoration(
                              labelText: 'Teknoloji',
                              isDense: true,
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Tüm teknolojiler',
                                    overflow: TextOverflow.ellipsis),
                              ),
                              for (final tech in availableTechnologies)
                                DropdownMenuItem<String?>(
                                  value: tech,
                                  child: Text(tech,
                                      overflow: TextOverflow.ellipsis),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _selectedTechnology = value),
                          ),
                        ),
                      if (_hasActiveFilters)
                        TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.filter_alt_off_outlined),
                          label: const Text('Filtreleri temizle'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('${projects.length} proje listeleniyor'),
                  const SizedBox(height: 12),
                  if (projects.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(36),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_rounded, size: 42),
                          const SizedBox(height: 12),
                          Text(
                            _hasActiveFilters
                                ? 'Seçilen kriterlere uygun proje bulunamadı.'
                                : 'Henüz yayınlanmış proje bulunmuyor.',
                            textAlign: TextAlign.center,
                          ),
                          if (_hasActiveFilters) ...[
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _clearFilters,
                              child: const Text('Filtreleri temizle'),
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final project in projects)
                          SizedBox(
                            width: width,
                            child: ProjectCard(
                              project: project,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProjectDetailScreen(
                                      projectId: project.id),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
