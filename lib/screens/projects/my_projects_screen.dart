import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../widgets/project_card.dart';
import '../../widgets/status_badge.dart';
import '../applications/incoming_applications_screen.dart';
import 'create_project_screen.dart';
import 'project_detail_screen.dart';

/// Kullanıcının sahibi olduğu projeler (tasarımdaki "Projelerim").
class MyProjectsScreen extends StatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  final _service = ProjectService();
  late final Stream<List<Project>> _projects = _service.streamMyProjects();

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projelerim'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => _push(const CreateProjectScreen()),
              icon: const Icon(Icons.add),
              label: const Text('Proje oluştur'),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Project>>(
        stream: _projects,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Projelerin yüklenemedi. Lütfen tekrar dene.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final projects = snapshot.data!;
          if (projects.isEmpty) {
            return const Center(child: Text('Henüz bir projen yok. "Proje oluştur" ile başlayabilirsin.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final project = projects[i];
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _push(ProjectDetailScreen(projectId: project.id)),
                                  child: Text(project.title,
                                      style: Theme.of(context).textTheme.titleMedium),
                                ),
                              ),
                              StatusBadge.project(project.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TagWrap(tags: project.technologies),
                          const Divider(height: 32),
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: () => _push(CreateProjectScreen(project: project)),
                                child: const Text('Projeyi düzenle'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    _push(IncomingApplicationsScreen(projectId: project.id)),
                                child: const Text('Başvuruları yönet'),
                              ),
                            ],
                          ),
                        ],
                      ),
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
