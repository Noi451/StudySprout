import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/format/duration_formatter.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/metric_tile.dart';
import '../../goals/domain/goal.dart';
import '../../goals/domain/goal_store_provider.dart';
import '../../goals/presentation/widgets/goal_create_dialog.dart';
import '../../progress/domain/progress_store_provider.dart';
import '../../sessions/domain/session_store.dart';
import '../../sessions/domain/session_store_provider.dart';
import '../../sessions/presentation/timer_page.dart';
import 'widgets/active_session_card.dart';
import 'widgets/growth_hero_card.dart';

/// หน้าหลัก (Home) — แท็บที่ 1
///
/// Sprint 8: รื้อ composition เป็น "Midnight Greenhouse" — Growth Hero เป็นพระเอก
///
/// Information Architecture:
///  A. Header (greeting + brand + date)
///  B. Compact Metric Strip (Level/XP, Study Today, Streak) — เฉพาะข้อมูลจริง
///  C. Growth Hero Card (tree illustration + stage + active goal + progress + CTA)
///  D. Secondary (active session card / goal empty state)
///
/// Responsive:
///  - Compact: single column, tree บน goal+CTA ล่าง
///  - Expanded: tree ขวา / goal+CTA ซ้าย (2/3 vs 1/3)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _openCreateGoalDialog(BuildContext context) async {
    final store = GoalStoreProvider.of(context);
    final goal = await GoalCreateDialog.showCreate(context, store.goals);
    if (goal != null) store.add(goal);
  }

  void _startStudy(BuildContext context, Goal goal) {
    final store = SessionStoreProvider.of(context);
    if (!store.isActive) store.startSession(goal);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TimerPage()));
  }

  @override
  Widget build(BuildContext context) {
    final goalStore = GoalStoreProvider.of(context);
    final progressStore = ProgressStoreProvider.of(context);
    final sessionStore = SessionStoreProvider.of(context);
    final activeGoal = goalStore.activeGoal;
    final stage = progressStore.treeStage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsivePageFrame(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xl,
                bottom: AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. Header
                  _HomeHeader(),
                  const SizedBox(height: AppSpacing.xl),

                  // B. Compact Metric Strip (เฉพาะข้อมูลจริง)
                  _MetricStrip(
                    level: progressStore.level,
                    levelXp: progressStore.currentLevelXp,
                    levelEndXp: progressStore.currentLevelEndXp,
                    todaySeconds: _todaySeconds(sessionStore),
                    hasActiveSession: sessionStore.isActive,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // C. Growth Hero Card
                  GrowthHeroCard(
                    stage: stage,
                    goal: activeGoal,
                    levelXp: progressStore.currentLevelXp,
                    levelEndXp: progressStore.currentLevelEndXp,
                    onStartStudy: activeGoal == null
                        ? null
                        : () => _startStudy(context, activeGoal),
                    onCreateGoal: () => _openCreateGoalDialog(context),
                    onGoalTap: () => context.go(AppRouter.goals),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // D. Secondary
                  if (sessionStore.isActive) ...[
                    const ActiveSessionCard(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// วินาทีเรียนวันนี้ — คำนวณจาก history จริง (ไม่ประดิษฐ์)
  int _todaySeconds(SessionStore store) {
    final now = DateTime.now();
    final today = store.history.where(
      (r) =>
          r.startedAt.year == now.year &&
          r.startedAt.month == now.month &&
          r.startedAt.day == now.day,
    );
    return today.fold(0, (sum, r) => sum + r.elapsedSeconds);
  }
}

/// A. Header — compact ไม่กินพื้นที่แนวตั้งมาก
class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('StudySprout', style: AppTextStyles.brand(context)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _todayLabel(),
                style: AppTextStyles.caption(context),
              ),
            ],
          ),
        ),
        // โลโก้เล็ก
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.emeraldContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
          ),
          child: const Icon(Icons.park, color: AppColors.emerald, size: 24),
        ),
      ],
    );
  }

  String _todayLabel() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

/// B. Metric strip — compact, เฉพาะข้อมูลจริง
class _MetricStrip extends StatelessWidget {
  const _MetricStrip({
    required this.level,
    required this.levelXp,
    required this.levelEndXp,
    required this.todaySeconds,
    required this.hasActiveSession,
  });

  final int level;
  final int levelXp;
  final int levelEndXp;
  final int todaySeconds;
  final bool hasActiveSession;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final expanded = AppBreakpoint.isExpanded(constraints.maxWidth);
        final tiles = <Widget>[
          Expanded(
            child: MetricTile(
              icon: Icons.bolt,
              label: 'Level $level',
              value: '$levelXp XP',
              accent: AppColors.growth,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: MetricTile(
              icon: Icons.today,
              label: 'Studied Today',
              value: DurationFormatter.fromSeconds(todaySeconds),
              accent: AppColors.time,
            ),
          ),
          if (expanded) ...[
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: MetricTile(
                icon: hasActiveSession ? Icons.timer : Icons.local_fire_department,
                label: hasActiveSession ? 'Studying Now' : 'Ready to Grow',
                value: hasActiveSession ? 'Active' : 'Tap Start',
                accent: hasActiveSession ? AppColors.time : AppColors.streak,
              ),
            ),
          ],
        ];
        return Row(children: tiles);
      },
    );
  }
}
