import 'package:flutter/material.dart';

import '../../models/project_application.dart';
import '../../services/project_service.dart';
import '../projects/project_detail_screen.dart';
import 'application_list.dart';

/// Kullanıcının gönderdiği başvurular ve durumları ("Başvurularım").
class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  late final Stream<List<ProjectApplication>> _applications =
      ProjectService().streamMyApplications();

  @override
  Widget build(BuildContext context) {
    return ApplicationTabs(
      title: 'Başvurularım',
      stream: _applications,
      emptyText: 'Bu listede başvuru yok.',
      itemBuilder: (context, application) => ApplicationTile(
        application: application,
        overline: 'Başvurduğun proje',
        title: application.projectTitle,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProjectDetailScreen(projectId: application.projectId)),
            ),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Projeyi gör'),
          ),
        ],
      ),
    );
  }
}
