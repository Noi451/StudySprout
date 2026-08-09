import 'package:flutter/material.dart';

import '../../../../core/format/duration_formatter.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_press_button.dart';
import '../../../../core/widgets/app_surface.dart';
import '../../../../core/widgets/empty_state_panel.dart';
import '../../../../core/widgets/hero_progress_bar.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../goals/domain/goal.dart';
import '../../../progress/domain/tree_stage.dart';
import 'growth_illustration.dart';

/// C. Growth Hero Card — หัวใจของ Home
///
/// รวม hierarchy: tree illustration + stage name + active goal + progress + CTA
///  - Compact (Sprint 8.1): single-column, padding กระชับ, ไม่ซ้อน card;
///    ลำดับ StageHeader → Illustration → Goal/Progress → CTA
///  - Expanded: tree ขวา / goal+stage+progress+CTA ซ้าย (2/3 + 1/3) — คงเดิม
///
/// Empty goal → compact แสดง EmptyStatePanel ในตัว (ไม่ซ้อนการ์ด);
/// expanded ใช้ AppSurface แยกตาม desktop baseline
class GrowthHeroCard extends StatelessWidget {
  const GrowthHeroCard({
    super.key,
    required this.stage,
    required this.goal,
    required this.levelXp,
    required this.levelEndXp,
    required this.onStartStudy,
    required this.onCreateGoal,
    required this.onGoalTap,
  });

  final TreeStage stage;
  final Goal? goal;
  final int levelXp;
  final int levelEndXp;
  final VoidCallback? onStartStudy;
  final VoidCallback onCreateGoal;
  final VoidCallback onGoalTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AppSurface(
      level: AppSurfaceLevel.base,
      radius: AppRadius.hero,
      elevated: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final expanded = AppBreakpoint.isExpanded(constraints.maxWidth);
          // Sprint 8.1: compact ใช้ padding กระชับกว่า (lg) เพื่อความรู้สึก mobile-first
          // expanded คง xxl ตาม desktop baseline
          final padding = expanded ? AppSpacing.xxl : AppSpacing.lg;
          return Padding(
            padding: EdgeInsets.all(padding),
            child: expanded
                ? _expanded(context, reduceMotion)
                : _compact(context, reduceMotion),
          );
        },
      ),
    );
  }

  // --- Compact: StageHeader → Illustration → Goal+CTA (single column) ---
  Widget _compact(BuildContext context, bool reduceMotion) {
    return Column(
      children: [
        _StageHeader(stage: stage, compact: true),
        const SizedBox(height: AppSpacing.md),
        Center(
          // 170 — อยู่ในช่วง 130–180, กลางการ์ดอย่าง intentional (halo circle)
          child: _Illustration(stage: stage, size: 170, reduceMotion: reduceMotion),
        ),
        const SizedBox(height: AppSpacing.lg),
        _GoalAndCta(
          goal: goal,
          levelXp: levelXp,
          levelEndXp: levelEndXp,
          onStartStudy: onStartStudy,
          onCreateGoal: onCreateGoal,
          onGoalTap: onGoalTap,
          compact: true,
        ),
      ],
    );
  }

  // --- Expanded: tree ขวา / goal+CTA ซ้าย (คงเดิม) ---
  Widget _expanded(BuildContext context, bool reduceMotion) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StageHeader(stage: stage, alignStart: true),
              const SizedBox(height: AppSpacing.lg),
              _GoalAndCta(
                goal: goal,
                levelXp: levelXp,
                levelEndXp: levelEndXp,
                onStartStudy: onStartStudy,
                onCreateGoal: onCreateGoal,
                onGoalTap: onGoalTap,
                compact: false,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xxl),
        Expanded(
          flex: 10,
          child: Center(
            child: _Illustration(stage: stage, size: 220, reduceMotion: reduceMotion),
          ),
        ),
      ],
    );
  }
}

/// ส่วนหัวของ Hero — stage pill + stage name + ข้อความการเติบโต
///
/// [compact] = true → ใช้ display ที่เล็กลง (displaySmall) เพื่อไม่ใหญ่เกินมือถือ
class _StageHeader extends StatelessWidget {
  const _StageHeader({required this.stage, this.alignStart = false, this.compact = false});

  final TreeStage stage;
  final bool alignStart;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final crossAxisAlignment =
        alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        StatusPill(
          label: 'Stage ${stage.index + 1}',
          accent: AppColors.emerald,
          icon: Icons.park,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          stage.label,
          style: compact
              ? AppTextStyles.display(context).copyWith(fontSize: 24)
              : AppTextStyles.display(context),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _growthMessage(stage),
          style: AppTextStyles.body(context),
          textAlign: alignStart ? TextAlign.start : TextAlign.center,
        ),
      ],
    );
  }

  String _growthMessage(TreeStage s) {
    switch (s) {
      case TreeStage.seed:
        return 'Your journey begins. Study to sprout.';
      case TreeStage.sprout:
        return 'A sprout appears. Keep going.';
      case TreeStage.smallPlant:
        return 'Growing steadily. Stay consistent.';
      case TreeStage.youngTree:
        return 'Branching out. You’re building momentum.';
      case TreeStage.tree:
        return 'A strong tree. Your habits are deep.';
      case TreeStage.bigTree:
        return 'A thriving giant. Remarkable dedication.';
    }
  }
}

/// ตัว illustration + entrance
class _Illustration extends StatelessWidget {
  const _Illustration({required this.stage, required this.size, required this.reduceMotion});

  final TreeStage stage;
  final double size;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1.0),
      duration: reduceMotion ? Duration.zero : AppMotion.entrance,
      curve: AppMotion.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: ((value - 0.94) / 0.06).clamp(0.0, 1.0),
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: GrowthIllustration(stage: stage, size: size),
    );
  }
}

/// ส่วน goal + progress + CTA (มี/ไม่มี goal)
///
/// [compact] = true → empty state แสดงในตัว (EmptyStatePanel compact + CTA เต็มกว้าง)
/// ไม่ซ้อน AppSurface อีกชั้น (กัน "card ซ้อน card" บนมือถือ)
class _GoalAndCta extends StatelessWidget {
  const _GoalAndCta({
    required this.goal,
    required this.levelXp,
    required this.levelEndXp,
    required this.onStartStudy,
    required this.onCreateGoal,
    required this.onGoalTap,
    required this.compact,
  });

  final Goal? goal;
  final int levelXp;
  final int levelEndXp;
  final VoidCallback? onStartStudy;
  final VoidCallback onCreateGoal;
  final VoidCallback onGoalTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // ไม่มี goal → empty state
    if (goal == null) {
      // compact: แสดงในตัว ไม่ซ้อนการ์ด — CTA เต็มกว้าง (thumb-friendly)
      if (compact) {
        return Column(
          children: [
            EmptyStatePanel(
              icon: Icons.flag_outlined,
              title: 'No Active Goal',
              caption: 'Create a goal to start growing your tree.',
              compact: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPressButton(
              label: 'Create Goal',
              onPressed: onCreateGoal,
              icon: Icons.add,
            ),
          ],
        );
      }
      // expanded: คง AppSurface แยกตาม desktop baseline
      return AppSurface(
        level: AppSurfaceLevel.high,
        radius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: EmptyStatePanel(
              icon: Icons.flag_outlined,
              title: 'No Active Goal',
              caption: 'Create a goal to start growing your tree.',
              action: AppPressButton(
                label: 'Create Goal',
                onPressed: onCreateGoal,
                isExpanded: false,
                icon: Icons.add,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active goal label
        Row(
          children: [
            const Icon(Icons.flag, color: AppColors.emerald, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Text('Active Goal', style: AppTextStyles.label(context)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        // ชื่อ goal (แตะ → ไป Goals)
        InkWell(
          onTap: onGoalTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: Text(goal!.title, style: AppTextStyles.cardTitle(context)),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          DurationFormatter.fromMinutes(goal!.targetMinutes),
          style: AppTextStyles.body(context),
        ),
        const SizedBox(height: AppSpacing.lg),
        // XP progress (เติบโตของต้นไม้ = Level XP)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Growth', style: AppTextStyles.label(context)),
            Text(
              '$levelXp / $levelEndXp XP',
              style: AppTextStyles.metricLabel(context)
                  .copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        HeroProgressBar(
          progress: levelXp / levelEndXp,
          accent: AppColors.emerald,
          showGlow: true,
        ),
        const SizedBox(height: AppSpacing.xxl),
        // CTA — primary เดียว เต็มกว้าง (thumb-friendly)
        AppPressButton(
          label: 'Start Study',
          onPressed: onStartStudy,
          icon: Icons.play_arrow,
        ),
      ],
    );
  }
}
