import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_surface.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../sessions/domain/session_status.dart';
import '../../../sessions/domain/session_store_provider.dart';
import '../../../sessions/presentation/session_format.dart';
import '../../../sessions/presentation/timer_page.dart';

/// การ์ดแสดงสถานะ "Session กำลังเรียนอยู่" บนหน้า Home
///
/// ถ้ามี session active (running/paused) จะแสดงการ์ด แตะเพื่อกลับเข้า Timer ต่อ
/// ถ้าไม่มี → คืน SizedBox.shrink (ไม่แสดง)
class ActiveSessionCard extends StatelessWidget {
  const ActiveSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final store = SessionStoreProvider.of(context);
    if (!store.isActive) return const SizedBox.shrink();

    final session = store.current!;
    final isRunning = session.status == SessionStatus.running;

    return AppSurface(
      level: AppSurfaceLevel.high,
      radius: AppRadius.card,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TimerPage()),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.timer, color: AppColors.emerald, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(
                    label: isRunning ? 'Studying now' : 'Paused',
                    accent: isRunning ? AppColors.emerald : AppColors.amber,
                    icon: isRunning ? Icons.play_arrow : Icons.pause,
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
            Text(
              SessionFormat.duration(store.elapsedSeconds),
              style: AppTextStyles.metricValue(context),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
