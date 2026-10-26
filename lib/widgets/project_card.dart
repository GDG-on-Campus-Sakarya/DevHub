import 'package:flutter/material.dart';
import '../models/project.dart';
import '../screens/projects/project_detail_screen.dart';
import 'status_badge.dart';

/// Ana sayfada ve proje listesinde kullanılan proje kartı.
///
/// [onTap] verilmezse kart proje detay ekranını açar. [onApply] verilirse
/// "Şimdi başvur" butonu gösterilir.
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onTap, this.onApply});
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onApply;

  void _openDetail(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: project.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () => _openDetail(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProjectCover(project: project, height: 120),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                  if (project.technologies.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const SectionLabel('Teknolojiler'),
                    const SizedBox(height: 8),
                    TagWrap(tags: project.technologies),
                  ],
                  if (project.neededRoles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.group_outlined, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionLabel('${project.neededRoles.length} açık pozisyon'),
                              const SizedBox(height: 4),
                              Text(
                                project.neededRoles.join(' · '),
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Proje sahibi · ${project.ownerName.isEmpty ? '—' : project.ownerName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: muted),
                        ),
                      ),
                      Icon(Icons.people_outline, size: 16, color: muted),
                      const SizedBox(width: 4),
                      Text('${project.memberIds.length} üye',
                          style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _openDetail(context),
                          child: const Text('Projeyi İncele'),
                        ),
                      ),
                      if (onApply != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: onApply,
                            child: const Text('Şimdi başvur'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tasarımdaki kapak alanı. Modelde görsel olmadığı için teknolojiye göre
/// degrade bir arka plan kullanılır.
class ProjectCover extends StatelessWidget {
  const ProjectCover({super.key, required this.project, this.height = 120});
  final Project project;
  final double height;

  static const List<List<Color>> _palettes = [
    [Color(0xFF1E2A78), Color(0xFF3B2A8C)],
    [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    [Color(0xFF0F172A), Color(0xFF334155)],
    [Color(0xFF1D4ED8), Color(0xFF6366F1)],
  ];

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[project.title.hashCode.abs() % _palettes.length];
    final isLight = palette.first.computeLuminance() > 0.5;
    final textColor = isLight ? const Color(0xFF14532D) : Colors.white;

    return Container(
      height: height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.code_rounded, size: 48, color: textColor.withValues(alpha: 0.35)),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: project.isOpen
                  ? const StatusBadge(label: 'Aktif ekip arıyor', color: Color(0xFF15803D))
                  : StatusBadge.project(project.status),
            ),
          ),
          if (project.technologies.isNotEmpty)
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                project.technologies.take(2).join(' · '),
                style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

/// Küçük, aralıklı büyük harfli bölüm etiketi (ör. "TEKNOLOJİLER").
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      trUpper(text),
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 1,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Çerçeveli teknoloji etiketleri.
class TagWrap extends StatelessWidget {
  const TagWrap({super.key, required this.tags});
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final tag in tags)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Text(tag, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ),
      ],
    );
  }
}
