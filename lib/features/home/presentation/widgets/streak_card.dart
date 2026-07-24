import 'package:flutter/material.dart';

/// การ์ด Streak (จำนวนวันที่เรียนติดต่อกัน) ของหน้า Home
///
/// แสดงไอคอนไฟ 🔥 และ "0 Day" เป็นข้อความคงที่
/// ยังไม่มี logic นับวันจริง — เป็น UI เพียงอย่างเดียว
class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ไอคอนไฟ — สีส้ม เป็นสัญลักษณ์ streak
            const Icon(
              Icons.local_fire_department,
              color: Color(0xFFFF6F00),
              size: 24,
            ),
            const SizedBox(height: 8),
            // จำนวนวัน — ตัวใหญ่ เด่น
            Text(
              '0 Day',
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
