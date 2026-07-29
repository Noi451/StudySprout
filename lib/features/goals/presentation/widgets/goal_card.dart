import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/format/duration_formatter.dart';
import '../../domain/goal.dart';

/// การ์ดแสดงรายการเป้าหมายหนึ่งรายการใน Goals Page
///
/// แสดงชื่อเป้าหมายและเป้าหมายเวลา (นาที) ในรูปแบบการ์ด Material 3
/// Sprint 3 เพิ่ม:
///  - ป้าย "Active" เมื่อเป็นเป้าหมายที่ active อยู่
///  - เมนู (PopupMenu) ต่อการ์ด: Set Active / Edit / Delete
///
/// เป็น UI ล้วน ๆ — ส่ง action กลับผ่าน callback ไม่มี business logic ในตัวการ์ด
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

  /// การ์ดนี้เป็นเป้าหมายที่ active อยู่หรือไม่ (ควบคุมป้าย "Active")
  final bool isActive;

  /// callback เมื่อเลือก "Set Active" จากเมนู
  final VoidCallback onSetActive;

  /// callback เมื่อเลือก "Edit"
  final VoidCallback onEdit;

  /// callback เมื่อเลือก "Delete"
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cardShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        boxShadow: cardShadow,
        // ขอบเขียวเด่นเมื่อเป็น active
        border: isActive
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // ไอคอนธงในวงกลมเขียวโปร่ง — สื่อ "เป้าหมาย"
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.flag : Icons.flag_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // ชื่อเป้าหมาย + เป้าหมายเวลา + ป้าย Active
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
                        _ActiveBadge(),
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
            // เมนูตัวเลือก (Set Active / Edit / Delete)
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

/// ป้ายเล็ก "Active" สีเขียว
class _ActiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        'Active',
        style: AppTextStyles.action(context),
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
      icon: const Icon(Icons.more_vert),
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
        // ถ้าเป็น active อยู่แล้ว → ซ่อนตัวเลือก Set Active
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
            leading: Icon(Icons.delete_outline),
            title: Text('Delete'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }
}

/// ตัวเลือกในเมนูการ์ดเป้าหมาย
enum _GoalAction { setActive, edit, delete }
