import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  factory StatusBadge.project(String status) => switch (status) {
        'open' => const StatusBadge(
            label: 'Ekip arıyor',
            color: Color(0xFF168567),
          ),
        'full' => const StatusBadge(
            label: 'Kontenjan dolu',
            color: Color(0xFF9B7214),
          ),
        'completed' => const StatusBadge(
            label: 'Tamamlandı',
            color: Color(0xFF3478D4),
          ),
        _ => const StatusBadge(
            label: 'Başvurular kapalı',
            color: Color(0xFF777777),
          ),
      };

  factory StatusBadge.application(String status) => StatusBadge(
        label: switch (status) {
          'accepted' => 'Kabul edildi',
          'rejected' => 'Reddedildi',
          _ => 'Beklemede',
        },
        color: switch (status) {
          'accepted' => const Color(0xFF168567),
          'rejected' => const Color(0xFFB53B3B),
          _ => const Color(0xFF9B7214),
        },
      );

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
