import 'package:flutter/material.dart';

import '../../../../core/format/duration_formatter.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_surface.dart';
import '../../../../core/widgets/empty_state_panel.dart';
import '../../../../core/widgets/section_header.dart';
import '../../sessions/domain/session_store_provider.dart';
import '../domain/progress_stats.dart';
import 'widgets/recent_session_tile.dart';

/// หน้าความคืบหน้า (Progress) — แท็บที่ 3
///
/// Sprint 8: ใช้ Product Identity ใหม่ + responsive frame + grid ตามพื้นที่
/// สถิติไม่ยืดเต็มจอ, ข้อมูลสำคัญก่อน, recent sessions อ่านง่าย
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
            ? const _EmptyState()
            : ResponsivePageFrame(
                child: ListView(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.xl,
                    bottom: AppSpacing.xxxl,
                  ),
                  children: [
                    // metric grid ตามพื้นที่ (compact=1col, medium/expanded=2col)
                    _StatGrid(stats: stats),
                    const SizedBox(height: AppSpacing.xxl),
                    const SectionHeader(title: 'Recent Sessions'),
                    ...stats.recent.map(
                      (record) => RecentSessionTile(record: record),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});
  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCol = !AppBreakpoint.isCompact(constraints.maxWidth);
        final crossCount = twoCol ? 2 : 1;
        // สำคัญก่อน: Today, Week, Total, Count, Average
        final tiles = <_StatTile>[
          _StatTile(
            label: "Today's Study Time",
            value: DurationFormatter.fromSeconds(stats.todaySeconds),
            icon: Icons.today,
            accent: AppColors.time,
          ),
          _StatTile(
            label: 'This Week',
            value: DurationFormatter.fromSeconds(stats.weekSeconds),
            icon: Icons.date_range,
            accent: AppColors.sky,
          ),
          _StatTile(
            label: 'Total Study Time',
            value: DurationFormatter.fromSeconds(stats.totalSeconds),
            icon: Icons.hourglass_bottom,
            accent: AppColors.growth,
          ),
          _StatTile(
            label: 'Sessions',
            value: '${stats.sessionCount}',
            icon: Icons.repeat,
            accent: AppColors.emerald,
          ),
          _StatTile(
            label: 'Average Length',
            value: DurationFormatter.fromSeconds(stats.averageSeconds),
            icon: Icons.analytics_outlined,
            accent: AppColors.amber,
          ),
        ];

        return _StaggerGrid(
          crossCount: crossCount,
          tiles: tiles,
        );
      },
    );
  }
}

/// การ์ดสถิติเดียว — compact, accent role, stagger entrance
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      level: AppSurfaceLevel.high,
      radius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.metricLabel(context)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(value, style: AppTextStyles.metricValue(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid แบบง่าย (crossCount 1/2) + stagger entrance
class _StaggerGrid extends StatelessWidget {
  const _StaggerGrid({required this.crossCount, required this.tiles});
  final int crossCount;
  final List<_StatTile> tiles;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += crossCount) {
      final row = <Widget>[];
      for (var j = 0; j < crossCount && i + j < tiles.length; j++) {
        row.add(Expanded(child: _StaggerReveal(index: i + j, child: tiles[i + j])));
        if (j < crossCount - 1) row.add(const SizedBox(width: AppSpacing.md));
      }
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: row));
      if (i + crossCount < tiles.length) {
        rows.add(const SizedBox(height: AppSpacing.md));
      }
    }
    return Column(children: rows);
  }
}

/// stagger reveal (slide up + fade)
class _StaggerReveal extends StatefulWidget {
  const _StaggerReveal({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_StaggerReveal> createState() => _StaggerRevealState();
}

class _StaggerRevealState extends State<_StaggerReveal> {
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(milliseconds: AppMotion.staggerStepMs * (widget.index + 1)),
      () {
        if (mounted) setState(() => _revealed = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _revealed ? Offset.zero : const Offset(0, 0.12),
      duration: AppMotion.medium,
      curve: AppMotion.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _revealed ? 1.0 : 0.0,
        duration: AppMotion.medium,
        curve: AppMotion.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Empty state — ซื่อสัตย์
/// Sprint 8.1: จัดให้อยู่ช่วงบน/กลางที่สมเหตุผล ไม่ลอยกลางพื้นที่ว่างมหาศาล
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xxxl * 3,
        ),
        child: Center(
          child: EmptyStatePanel(
            icon: Icons.insights_outlined,
            title: 'No Study Sessions Yet',
            caption: 'Finish a study session to see your progress here.',
          ),
        ),
      ),
    );
  }
}
