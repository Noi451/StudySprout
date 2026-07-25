import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../goals/domain/goal.dart';
import '../../../sessions/domain/session_store_provider.dart';
import '../../../sessions/presentation/timer_page.dart';

/// ปุ่ม "Start Study" ขนาดใหญ่ด้านล่างหน้า Home
///
/// กติกาตาม Sprint 2:
///  - ถ้ายังไม่มี Goal → ปุ่ม disabled + ข้อความชวนสร้าง Goal ก่อน
///  - ถ้ามี Goal → กดเพื่อเริ่ม/เปิดหน้า Timer
///    • ถ้ามี session active อยู่แล้ว → เปิดหน้า Timer ของ session เดิม (ไม่ start ทับ)
///    • ถ้ายังไม่มี → สั่ง [SessionStore.startSession] แล้วเปิด Timer
class StartStudyButton extends StatelessWidget {
  const StartStudyButton({super.key, this.goal});

  /// เป้าหมายล่าสุด (ถ้ามี) — null = ยังไม่มี Goal → ปุ่ม disabled
  final Goal? goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasGoal = goal != null;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        // disabled เมื่อยังไม่มี Goal
        onPressed: hasGoal ? () => _start(context) : null,
        style: FilledButton.styleFrom(
          // ปุ่มโค้งตาม Design System
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl - 8),
          backgroundColor: theme.colorScheme.primary,
        ),
        child: Text(
          hasGoal ? 'Start Study' : 'Create a goal to start',
          style: AppTextStyles.button(context),
        ),
      ),
    );
  }

  /// เริ่ม session แล้วเปิดหน้า Timer
  void _start(BuildContext context) {
    final store = SessionStoreProvider.of(context);

    // ถ้ายังไม่มี session active → เริ่ม session ใหม่จาก goal ล่าสุด
    // (ถ้ามี active อยู่แล้ว → ไม่ start ทับ เปิด timer เดิมต่อ)
    if (!store.isActive) {
      store.startSession(goal!);
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TimerPage()),
    );
  }
}
