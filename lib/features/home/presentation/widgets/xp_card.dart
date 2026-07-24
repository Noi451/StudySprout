import 'package:flutter/material.dart';

/// การ์ด XP (ค่าประสบการณ์) ของหน้า Home
///
/// แสดง "Level 1" และ "XP 0 / 100" เป็นข้อความคงที่
/// ยังไม่มี logic คำนวณระดับหรือ XP จริง — เป็น UI เพียงอย่างเดียว
class XpCard extends StatelessWidget {
  const XpCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ป้ายระดับ — เล็ก สีอ่อน อยู่บนสุด
            Text(
              'Level 1',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            // ค่า XP — ตัวใหญ่ เด่น
            Text(
              'XP 0 / 100',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
