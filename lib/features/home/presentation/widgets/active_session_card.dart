import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../sessions/domain/session_status.dart';
import '../../../sessions/domain/session_store_provider.dart';
import '../../../sessions/presentation/session_format.dart';
import '../../../sessions/presentation/timer_page.dart';

/// การ์ดแสดงสถานะ "Session กำลังเรียนอยู่" บนหน้า Home
///
/// ดึงจาก [SessionStoreProvider] — ถ้ามี session active (running/paused) จะแสดงการ์ดเล็ก ๆ
/// บอกชื่อ Goal, เวลาที่ผ่าน และสถานะ แตะการ์ดเพื่อกลับเข้าหน้า Timer ต่อ
/// ถ้าไม่มี session active → คืน [SizedBox.shrink] (ไม่แสดงอะไร)
class ActiveSessionCard extends StatelessWidget {
  const ActiveSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final store = SessionStoreProvider.of(context);

    // ไม่มี session active → ไม่แสดง
    if (!store.isActive) return const SizedBox.shrink();

    final session = store.current!;
    final isRunning = session.status == SessionStatus.running;
    final theme = Theme.of(context);

    final cardShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.card,
          boxShadow: cardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.card,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TimerPage()),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // ไอคอน timer ในวงกลมเขียวโปร่ง
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.timer,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // ชื่อ session + เวลา
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRunning ? 'Studying now' : 'Paused',
                          style: AppTextStyles.label(context),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          session.goalTitle,
                          style: AppTextStyles.cardTitle(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // เวลาที่ผ่าน (mm:ss)
                  Text(
                    SessionFormat.duration(store.elapsedSeconds),
                    style: AppTextStyles.value(context),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
