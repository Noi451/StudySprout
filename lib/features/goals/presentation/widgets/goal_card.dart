import 'package:flutter/material.dart';

import '../../../../core/format/duration_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_surface.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/goal.dart';

/// การ์ดแสดงรายการเป้าหมายหนึ่งรายการใน Goals Page
///
/// Sprint 8: ใช้ Product Identity ใหม่ — active เด่นด้วยขอบ emerald (ไม่แสบตา)
/// + ป้าย Active pill + InkWell splash/hover
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.isActive,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
  });

  final Goal goal;
  final bool isActive;
  final VoidCallback onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      level: AppSurfaceLevel.base,
      radius: AppRadius.card,
      borderOverride: isActive ? AppColors.emerald.withValues(alpha: 0.6) : null,
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // ไอคอนธงใน chip
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                isActive ? Icons.flag : Icons.flag_outlined,
                color: AppColors.emerald,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          goal.title,
                          style: AppTextStyles.cardTitle(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const StatusPill(label: 'Active', accent: AppColors.emerald),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    DurationFormatter.fromMinutes(goal.targetMinutes),
                    style: AppTextStyles.body(context),
                  ),
                ],
              ),
            ),
            _GoalMenu(
              isActive: isActive,
              onSetActive: onSetActive,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

/// เมนูตัวเลือกของการ์ดเป้าหมาย
class _GoalMenu extends StatelessWidget {
  const _GoalMenu({
    required this.isActive,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
  });

  final bool isActive;
  final VoidCallback onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_GoalAction>(
      // Sprint 8.1: padding 12 รอบ icon 24 → touch target 48×48 (mobile)
      icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
      padding: const EdgeInsets.all(12),
      tooltip: 'Goal options',
      onSelected: (action) {
        switch (action) {
          case _GoalAction.setActive:
            onSetActive();
          case _GoalAction.edit:
            onEdit();
          case _GoalAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => [
        if (!isActive)
          const PopupMenuItem(
            value: _GoalAction.setActive,
            child: ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Set Active'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
        const PopupMenuItem(
          value: _GoalAction.edit,
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: _GoalAction.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: AppColors.danger),
            title: Text('Delete', style: TextStyle(color: AppColors.danger)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }
}

enum _GoalAction { setActive, edit, delete }
