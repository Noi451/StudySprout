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
/// Sprint 8: ยังไม่มีข้อมูลจริง (ไม่มี avatar/name/settings store) →
/// ทำ foundation screen ที่ polished แต่ซื่อสัตย์ — ระบุว่าส่วนต่าง ๆ "Coming later"
/// ห้ามสร้าง avatar/name/settings ปลอม (ตามกฎ)
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
              AppSurface(
                level: AppSurfaceLevel.base,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.emerald,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: const Icon(Icons.park, color: AppColors.onEmerald, size: 40),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('StudySprout', style: AppTextStyles.brand(context)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Your study companion',
                        style: AppTextStyles.body(context),
                      ),
                    ],
                  ),
                ),
              ),
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

class _ComingLaterTile extends StatelessWidget {
  const _ComingLaterTile({required this.item});
  final _ComingItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppSurface(
        level: AppSurfaceLevel.high,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
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
                decoration: BoxDecoration(
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
  }
}
