import 'package:flutter/material.dart';

import '../../../../core/format/duration_formatter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../sessions/domain/session_store_provider.dart';
import '../domain/progress_stats.dart';
import 'widgets/progress_stat_card.dart';
import 'widgets/recent_session_tile.dart';

/// หน้าความคืบหน้า (Progress) — แท็บที่ 3
///
/// Sprint 4: แสดงสถิติการเรียนจากประวัติ session จริง (`List<SessionRecord>`)
/// ที่ดึงจาก [SessionStoreProvider] — คำนวณผ่าน [ProgressStats.compute]
/// (logic ทั้งหมดอยู่ใน domain layer ไม่มี business logic ใน widget)
///
/// สถิติที่แสดง:
///  - Today's Study Time   เวลาเรียนสะสมวันนี้
///  - This Week Study Time เวลาเรียนสะสมสัปดาห์นี้ (จันทร์–อาทิตย์)
///  - Total Study Time     เวลาเรียนสะสมทั้งหมด
///  - Session Count        จำนวน session ทั้งหมด
///  - Average Session Length ความยาวเฉลี่ยต่อ session
///  - Recent Sessions      5 session ล่าสุด
///
/// เป็น StatelessWidget — state อยู่ใน store, rebuild ผ่าน InheritedNotifier
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = SessionStoreProvider.of(context);
    final stats = ProgressStats.compute(store.history, DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: SafeArea(
        child: stats.sessionCount == 0
            ? _EmptyState()
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  // สถิติหลัก 3 ตัว — Today / Week / Total (เต็มกว้าง ทีละใบ)
                  ProgressStatCard(
                    label: "Today's Study Time",
                    value: DurationFormatter.fromSeconds(stats.todaySeconds),
                    icon: Icons.today,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ProgressStatCard(
                    label: 'This Week Study Time',
                    value: DurationFormatter.fromSeconds(stats.weekSeconds),
                    icon: Icons.date_range,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ProgressStatCard(
                    label: 'Total Study Time',
                    value: DurationFormatter.fromSeconds(stats.totalSeconds),
                    icon: Icons.hourglass_bottom,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Session Count + Average วางคู่กัน 2 คอลัมน์
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ProgressStatCard(
                            label: 'Session Count',
                            value: '${stats.sessionCount}',
                            icon: Icons.repeat,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ProgressStatCard(
                            label: 'Average Length',
                            value: DurationFormatter.fromSeconds(
                              stats.averageSeconds,
                            ),
                            icon: Icons.analytics_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // หัวข้อ Recent Sessions
                  Text('Recent Sessions', style: AppTextStyles.cardTitle(context)),
                  const SizedBox(height: AppSpacing.sm),
                  // รายการ 5 session ล่าสุด
                  ...stats.recent.map(
                    (record) => RecentSessionTile(record: record),
                  ),
                ],
              ),
      ),
    );
  }
}

/// สถานะว่างของหน้า Progress — ยังไม่มีประวัติการเรียน
///
/// ไม่ใช้ fake data (ตามกฎโปรเจกต์) — แสดงข้อความชวนเริ่มเรียนแทน
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ไอคอนกราฟในวงกลมเขียวโปร่ง
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insights_outlined,
                color: theme.colorScheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No Study Sessions Yet', style: AppTextStyles.cardTitle(context)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Finish a study session to see your progress here',
              style: AppTextStyles.body(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
