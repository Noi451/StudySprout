import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Empty state ที่ดู intentional — icon + title + caption + (optional) action
///
/// ใช้แทนการ์ดเล็กโดดเดี่ยว ซื่อสัตย์ (ไม่ประดิษฐ์ข้อมูล) ตามกฎ Sprint 8
class EmptyStatePanel extends StatelessWidget {
  const EmptyStatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.caption,
    this.action,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String caption;
  final Widget? action;

  /// true = ขนาดเล็ก (ในการ์ด/พื้นที่จำกัด)
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 32.0 : 48.0;
    final chipSize = compact ? 56.0 : 80.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: chipSize,
          height: chipSize,
          decoration: BoxDecoration(
            color: AppColors.emerald.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.emerald.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Icon(icon, color: AppColors.emerald, size: iconSize),
        ),
        SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
        Text(title, style: AppTextStyles.cardTitle(context), textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        Text(
          caption,
          style: AppTextStyles.body(context),
          textAlign: TextAlign.center,
        ),
        if (action != null) ...[
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          action!,
        ],
      ],
    );
  }
}
