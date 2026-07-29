import 'package:flutter/material.dart';

import '../../../../core/format/duration_formatter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../sessions/domain/session_record.dart';

/// แถวรายการ session หนึ่งรายการในส่วน "Recent Sessions" ของหน้า Progress
///
/// แสดง: ไอคอน + ชื่อ Goal + วันที่ (เริ่ม) + เวลาที่เรียน (ผ่าน formatter กลาง)
///
/// เป็น UI ล้วน ๆ — รับ [SessionRecord] มาแสดงเท่านั้น ไม่มี business logic
class RecentSessionTile extends StatelessWidget {
  const RecentSessionTile({super.key, required this.record});

  final SessionRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          // ไอคอนในวงกลมเขียวโปร่ง
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timer_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // ชื่อ Goal + วันที่
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.goalTitle,
                  style: AppTextStyles.cardTitle(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatDate(record.startedAt),
                  style: AppTextStyles.body(context),
                ),
              ],
            ),
          ),
          // เวลาที่เรียน (formatter กลาง)
          Text(
            DurationFormatter.fromSeconds(record.elapsedSeconds),
            style: AppTextStyles.value(context),
          ),
        ],
      ),
    );
  }

  /// จัดรูปแบบวันที่แบบสั้น เช่น "Jul 29, 2026"
  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
