import 'package:flutter/material.dart';
import '../../models/project_application.dart';
import '../../widgets/status_badge.dart';

class ApplicationList extends StatelessWidget {
  const ApplicationList({super.key, required this.applications});
  final List<ProjectApplication> applications;
  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) return const Center(child: Text('Gösterilecek başvuru yok.'));
    return ListView.separated(itemCount: applications.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (context, index) {
      final a = applications[index];
      return Card(child: ListTile(title: Text(a.projectTitle), subtitle: Text(a.message, maxLines: 2, overflow: TextOverflow.ellipsis), trailing: StatusBadge.application(a.status)));
    });
  }
}
