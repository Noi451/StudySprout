import 'package:flutter/material.dart';

/// การ์ด "เป้าหมายของวันนี้" ของหน้า Home
///
/// แสดงสถานะว่ายังไม่มีเป้าหมาย — "No Goal Yet" และคำชวน "Create your first goal"
/// ยังไม่มี logic สร้าง/โหลดเป้าหมายจริง — เป็น UI เพียงอย่างเดียว
class GoalCard extends StatelessWidget {
  const GoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // ไอคอนธง — สื่อถึง "เป้าหมาย"
            Icon(
              Icons.flag_outlined,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // หัวข้อการ์ด
                  Text(
                    "Today's Goal",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // สถานะ "ยังไม่มีเป้าหมาย"
                  Text(
                    'No Goal Yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // คำชวนสร้างเป้าหมายแรก
                  Text(
                    'Create your first goal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
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
