import 'package:flutter/material.dart';

import '../models/project.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

/// Ana sayfa ve proje listesinde tekrar kullanılabilen proje kartı.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.compact = false,
  });

  final Project project;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final technologies = project.technologies.take(compact ? 2 : 3).toList();

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(compact ? 18 : 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _projectColor(project.title).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _projectIcon(project.title),
                      color: _projectColor(project.title),
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  StatusBadge.project(project.effectiveStatus),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                project.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (project.category != null) ...[
                const SizedBox(height: 4),
                Text(
                  project.category!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                project.description,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final technology in technologies)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.softPurple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        technology,
                        style: const TextStyle(
                          color: AppTheme.primaryDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (project.technologies.length > technologies.length)
                    Text(
                      '+${project.technologies.length - technologies.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 13),
              Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor:
                        _projectColor(project.title).withOpacity(0.14),
                    child: Text(
                      _ownerInitials(project.ownerName.isEmpty
                          ? 'DevHub'
                          : project.ownerName),
                      style: TextStyle(
                        color: _projectColor(project.title),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      project.ownerName.isEmpty
                          ? 'DevHub üyesi'
                          : project.ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _projectColor(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('eco') || normalized.contains('green')) {
      return const Color(0xFF159B78);
    }
    if (normalized.contains('data') || normalized.contains('ai')) {
      return const Color(0xFF3478D4);
    }
    if (normalized.contains('design') || normalized.contains('campus')) {
      return const Color(0xFFDE8C32);
    }
    return AppTheme.primary;
  }

  static IconData _projectIcon(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('eco') || normalized.contains('green')) {
      return Icons.eco_rounded;
    }
    if (normalized.contains('data') || normalized.contains('ai')) {
      return Icons.auto_awesome_rounded;
    }
    if (normalized.contains('design') || normalized.contains('campus')) {
      return Icons.draw_rounded;
    }
    return Icons.code_rounded;
  }

  static String _ownerInitials(String owner) {
    final parts = owner.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'DH';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
