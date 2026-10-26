import 'package:flutter/material.dart';

import '../models/project.dart';
import '../models/project_application.dart';

/// Tasarımdaki yuvarlak durum rozeti (ör. "● BEKLEMEDE").
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});

  // Proje durumu için rozet
  factory StatusBadge.project(String status, {Key? key}) =>
      status == Project.statusOpen
          ? StatusBadge(key: key, label: 'Başvurulara açık', color: _green)
          : StatusBadge(key: key, label: 'Başvurulara kapalı', color: _grey);

  // Başvuru durumu için rozet; veritabanındaki İngilizce değerler Türkçe gösterildi
  factory StatusBadge.application(String status, {Key? key}) =>
      StatusBadge(
        key: key,
        label: applicationStatusLabel(status),
        color: switch (status) {
          ProjectApplication.statusAccepted => _green,
          ProjectApplication.statusRejected => _red,
          _ => _amber,
        },
      );

  static const Color _green = Color(0xFF15803D);
  static const Color _amber = Color(0xFFB45309);
  static const Color _red = Color(0xFFB91C1C);
  static const Color _grey = Color(0xFF64748B);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            trUpper(label),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

// Dart'ın toUpperCase metodu Türkçe "i" harfini "I" yapar; önce "i" → "İ" dönüştürüldü
String trUpper(String text) => text.replaceAll('i', 'İ').toUpperCase();

String applicationStatusLabel(String status) => switch (status) {
      ProjectApplication.statusAccepted => 'Kabul edildi',
      ProjectApplication.statusRejected => 'Reddedildi',
      _ => 'Beklemede',
    };
