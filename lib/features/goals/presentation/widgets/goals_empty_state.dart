import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// สถานะว่าง (Empty State) ของ Goals Page
///
/// แสดงเมื่อยังไม่มีเป้าหมายใด ๆ — มีไอคอนในวงกลม ข้อความบอกสถานะ
/// และปุ่ม "Create Goal" ให้ผู้ใช้เริ่มสร้างเป้าหมายแรก
class GoalsEmptyState extends StatelessWidget {
  const GoalsEmptyState({super.key, required this.onCreate});

  /// callback เมื่อกดปุ่ม Create Goal
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ไอคอนธงในวงกลมพื้นหลังเขียวโปร่ง
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flag_outlined,
                color: theme.colorScheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No Goals Yet', style: AppTextStyles.cardTitle(context)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Create your first goal to start',
              style: AppTextStyles.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            // ปุ่มสร้างเป้าหมาย
            FilledButton.icon(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.md,
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Create Goal'),
            ),
          ],
        ),
      ),
    );
  }
}
