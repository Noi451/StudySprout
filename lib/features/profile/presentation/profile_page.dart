import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_surface.dart';
import '../../../../core/widgets/section_header.dart';

/// หน้าโปรไฟล์ (Profile) — แท็บที่ 4
///
/// Sprint 8: foundation screen ซื่อสัตย์ (Coming Later) — ห้ามสร้าง avatar/name/settings ปลอม
/// Sprint 8.1: compact ลด padding/logo และ Coming Later tiles ให้กระชับ mobile-first
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ResponsivePageFrame(
          child: ListView(
            padding: const EdgeInsets.only(
              top: AppSpacing.xxl,
              bottom: AppSpacing.xxxl,
            ),
            children: [
              // ส่วนบน: โลโก้แบรนด์ + สถานะ foundation
              _ProfileHero(),
              const SizedBox(height: AppSpacing.xxl),
              const SectionHeader(title: 'Coming Later'),
              ..._comingLater.map((item) => _ComingLaterTile(item: item)),
            ],
          ),
        ),
      ),
    );
  }

  /// รายการที่วางไว้ในอนาคต (foundation จริง ไม่ใช่ข้อมูลปลอม)
  static const _comingLater = [
    _ComingItem(
      icon: Icons.account_circle_outlined,
      title: 'Account',
      caption: 'Sign in and sync your progress across devices.',
    ),
    _ComingItem(
      icon: Icons.tune_outlined,
      title: 'Preferences',
      caption: 'Customize study reminders and app behavior.',
    ),
    _ComingItem(
      icon: Icons.emoji_events_outlined,
      title: 'Achievements',
      caption: 'Track milestones and badges as your tree grows.',
    ),
  ];
}

/// Profile hero — compact ลด padding + logo เล็กลง; expanded คงขนาด desktop
class _ProfileHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = AppBreakpoint.isCompact(constraints.maxWidth);
        final padding = compact ? AppSpacing.xl : AppSpacing.xxl;
        final logoSize = compact ? 56.0 : 72.0;
        final logoIcon = compact ? 32.0 : 40.0;

        return AppSurface(
          level: AppSurfaceLevel.base,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    color: AppColors.emerald,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Icon(Icons.park, color: AppColors.onEmerald, size: logoIcon),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('StudySprout', style: AppTextStyles.brand(context)),
                const SizedBox(height: AppSpacing.xs),
                Text('Your study companion', style: AppTextStyles.body(context)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ComingItem {
  const _ComingItem({
    required this.icon,
    required this.title,
    required this.caption,
  });
  final IconData icon;
  final String title;
  final String caption;
}

/// Coming Later row — compact กระชับ padding; description wrap ได้ ห้าม overflow
class _ComingLaterTile extends StatelessWidget {
  const _ComingLaterTile({required this.item});
  final _ComingItem item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = AppBreakpoint.isCompact(constraints.maxWidth);
        final padding = compact ? AppSpacing.md : AppSpacing.lg;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: AppSurface(
            level: AppSurfaceLevel.high,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                children: [
                  Icon(item.icon, color: AppColors.emerald, size: 24),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: AppTextStyles.cardTitle(context)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(item.caption, style: AppTextStyles.body(context)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.outlineSoft,
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text('Soon', style: AppTextStyles.caption(context)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
