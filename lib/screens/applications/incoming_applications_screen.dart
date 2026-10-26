import 'package:flutter/material.dart';

import '../../models/project_application.dart';
import '../../services/project_service.dart';
import '../projects/project_detail_screen.dart';
import 'application_list.dart';

/// Proje sahibinin projelerine gelen başvurular ("Gelen Başvurular").
/// [projectId] verilirse yalnızca o projenin başvuruları listelenir.
class IncomingApplicationsScreen extends StatefulWidget {
  const IncomingApplicationsScreen({super.key, this.projectId});
  final String? projectId;

  @override
  State<IncomingApplicationsScreen> createState() => _IncomingApplicationsScreenState();
}

class _IncomingApplicationsScreenState extends State<IncomingApplicationsScreen> {
  final _service = ProjectService();
  late final Stream<List<ProjectApplication>> _applications =
      _service.streamIncomingApplications(projectId: widget.projectId);

  // Karar verilen başvurular; çift tıklamayı engellemek için tutuldu
  final Set<String> _busy = {};

  Future<void> _decide(ProjectApplication application, bool accept) async {
    if (!accept) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Başvuruyu reddet'),
          content: Text('${application.applicantName} adlı kişinin başvurusu reddedilsin mi?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reddet')),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _busy.add(application.id));
    try {
      await _service.decideApplication(application, accept: accept);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(accept
            ? '${application.applicantName} ekibe eklendi.'
            : 'Başvuru reddedildi.'),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy.remove(application.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ApplicationTabs(
      title: 'Gelen Başvurular',
      stream: _applications,
      emptyText: 'Bu listede başvuru yok.',
      itemBuilder: (context, application) {
        final busy = _busy.contains(application.id);
        return ApplicationTile(
          application: application,
          overline: 'Başvurulan proje: ${application.projectTitle}',
          title: application.applicantName,
          actions: application.isPending
              ? [
                  OutlinedButton(
                    onPressed: busy ? null : () => _decide(application, false),
                    child: const Text('Reddet'),
                  ),
                  FilledButton(
                    onPressed: busy ? null : () => _decide(application, true),
                    child: const Text('Kabul et'),
                  ),
                ]
              : [
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
        );
      },
    );
  }
}
