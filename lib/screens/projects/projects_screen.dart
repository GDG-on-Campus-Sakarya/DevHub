import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../widgets/project_card.dart';
import 'create_project_screen.dart';
import 'project_detail_screen.dart';
import 'my_projects_screen.dart';
import '../applications/applications_screen.dart';
import '../applications/incoming_applications_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});
  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _service = ProjectService();
  late final Stream<List<Project>> _projects = _service.streamOpenProjects();
  final _query = TextEditingController();
  @override
  void dispose() { _query.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Projeleri keşfet'), actions: [
      if (_service.canContribute) PopupMenuButton<String>(onSelected: (v) {
        Widget page = switch (v) { 'mine' => const MyProjectsScreen(), 'sent' => const ApplicationsScreen(), _ => const IncomingApplicationsScreen() };
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      }, itemBuilder: (_) => const [PopupMenuItem(value: 'mine', child: Text('Projelerim')), PopupMenuItem(value: 'sent', child: Text('Başvurularım')), PopupMenuItem(value: 'incoming', child: Text('Gelen başvurular'))]),
      if (_service.canContribute) IconButton(tooltip: 'Proje oluştur', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateProjectScreen())), icon: const Icon(Icons.add)),
    ]),
    body: StreamBuilder<List<Project>>(
      stream: _projects,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Projeler yüklenemedi: ${snapshot.error}')));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final q = _query.text.trim().toLowerCase();
        final projects = snapshot.data!.where((p) {
          if (q.isEmpty) return true;
          return p.title.toLowerCase().contains(q) || p.description.toLowerCase().contains(q) || p.technologies.any((e) => e.toLowerCase().contains(q)) || p.neededRoles.any((e) => e.toLowerCase().contains(q));
        }).toList();
        return LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth > 1000 ? 3 : constraints.maxWidth > 650 ? 2 : 1;
          final gap = 16.0; final padding = constraints.maxWidth > 650 ? 28.0 : 16.0;
          final width = (constraints.maxWidth - padding * 2 - gap * (columns - 1)) / columns;
          return ListView(padding: EdgeInsets.all(padding), children: [
            Text('Projeni paylaş, ekibini bul.', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8), const Text('Açık öğrenci projelerini keşfet; ilgini çeken projeye başvur.'),
            const SizedBox(height: 20),
            TextField(controller: _query, onChanged: (_) => setState(() {}), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Proje, teknoloji veya rol ara')),
            const SizedBox(height: 16),
            Text('${projects.length} açık proje'), const SizedBox(height: 12),
            if (projects.isEmpty) const Padding(padding: EdgeInsets.all(36), child: Center(child: Text('Henüz eşleşen açık proje yok.')))
            else Wrap(spacing: gap, runSpacing: gap, children: [for (final project in projects) SizedBox(width: width, child: ProjectCard(project: project, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: project.id)))))]),
          ]);
        });
      },
    ),
  );
}
