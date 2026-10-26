import 'package:flutter/material.dart';

import '../../models/project_application.dart';
import '../../widgets/status_badge.dart';

/// Başvurularım ve Gelen Başvurular ekranlarının ortak gövdesi:
/// Tümü / Beklemede / Kabul Edildi / Reddedildi sekmeleri.
class ApplicationTabs extends StatelessWidget {
  const ApplicationTabs({
    super.key,
    required this.title,
    required this.stream,
    required this.itemBuilder,
    required this.emptyText,
  });

  final String title;
  final Stream<List<ProjectApplication>> stream;
  final Widget Function(BuildContext, ProjectApplication) itemBuilder;
  final String emptyText;

  static const _filters = <String?>[
    null,
    ProjectApplication.statusPending,
    ProjectApplication.statusAccepted,
    ProjectApplication.statusRejected,
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProjectApplication>>(
      stream: stream,
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <ProjectApplication>[];
        return DefaultTabController(
          length: _filters.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(title),
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  for (final f in _filters)
                    Tab(
                      text: f == null
                          ? 'Tümü (${all.length})'
                          : '${applicationStatusLabel(f)} (${all.where((a) => a.status == f).length})',
                    ),
                ],
              ),
            ),
            body: snapshot.hasError
                ? const Center(child: Text('Başvurular yüklenemedi. Lütfen tekrar dene.'))
                : !snapshot.hasData
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        children: [
                          for (final f in _filters)
                            _List(
                              items: f == null ? all : all.where((a) => a.status == f).toList(),
                              itemBuilder: itemBuilder,
                              emptyText: emptyText,
                            ),
                        ],
                      ),
          ),
        );
      },
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.items, required this.itemBuilder, required this.emptyText});
  final List<ProjectApplication> items;
  final Widget Function(BuildContext, ProjectApplication) itemBuilder;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(emptyText)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: itemBuilder(context, items[i]),
        ),
      ),
    );
  }
}

/// Tek bir başvuru kartı. [actions] sağ alt köşede gösterilir.
class ApplicationTile extends StatelessWidget {
  const ApplicationTile({
    super.key,
    required this.application,
    required this.overline,
    required this.title,
    this.actions = const [],
  });

  final ProjectApplication application;
  final String overline;
  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final initials = title.trim().isEmpty
        ? '?'
        : title.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0].toUpperCase()).join();

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(initials, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(overline, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                  const SizedBox(height: 4),
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('"${application.message}"', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text('Gönderim: ${relativeTime(application.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge.application(application.status),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.end, children: actions),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String relativeTime(DateTime? time) {
  if (time == null) return 'az önce';
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'az önce';
  if (diff.inHours < 1) return '${diff.inMinutes} dakika önce';
  if (diff.inDays < 1) return '${diff.inHours} saat önce';
  return '${diff.inDays} gün önce';
}
