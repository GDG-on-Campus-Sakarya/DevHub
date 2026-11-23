import 'package:flutter/material.dart';
import '../../models/project_application.dart';
import '../../services/project_service.dart';
import '../../widgets/status_badge.dart';

class IncomingApplicationsScreen extends StatefulWidget {
  const IncomingApplicationsScreen({super.key, this.projectId});
  final String? projectId;
  @override
  State<IncomingApplicationsScreen> createState() => _IncomingApplicationsScreenState();
}
class _IncomingApplicationsScreenState extends State<IncomingApplicationsScreen> {
  final _service = ProjectService();
  final Set<String> _busy = {};
  Future<void> _decide(ProjectApplication a, bool accept) async {
    setState(() => _busy.add(a.id));
    try {
      await _service.decideApplication(a, accept: accept);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(accept ? 'Başvuru kabul edildi.' : 'Başvuru reddedildi.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).colorScheme.error));
    } finally { if (mounted) setState(() => _busy.remove(a.id)); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Gelen başvurular')), body: StreamBuilder<List<ProjectApplication>>(
    stream: _service.streamIncomingApplications(projectId: widget.projectId),
    builder: (context, snapshot) {
      if (snapshot.hasError) return Center(child: Text('Başvurular alınamadı: ${snapshot.error}'));
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final list = snapshot.data!;
      if (list.isEmpty) return const Center(child: Text('Henüz gelen başvuru yok.'));
      return ListView.separated(padding: const EdgeInsets.all(16), itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (context, i) {
        final a=list[i]; final pending=a.isPending; final busy=_busy.contains(a.id);
        return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(a.projectTitle, style: Theme.of(context).textTheme.titleMedium)), StatusBadge.application(a.status)]),
          const SizedBox(height: 6), Text('Başvuran: ${a.applicantName.isEmpty ? 'DevHub üyesi' : a.applicantName}'), const SizedBox(height: 10), Text(a.message),
          if (pending) ...[const SizedBox(height: 12), Row(children: [Expanded(child: OutlinedButton(onPressed: busy ? null : () => _decide(a, false), child: const Text('Reddet'))), const SizedBox(width: 10), Expanded(child: FilledButton(onPressed: busy ? null : () => _decide(a, true), child: busy ? const CircularProgressIndicator() : const Text('Kabul et')))])]
        ])));
      });
    },
  ));
}
