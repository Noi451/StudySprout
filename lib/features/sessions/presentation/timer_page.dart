import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/session_status.dart';
import '../domain/session_store_provider.dart';
import 'session_format.dart';
import 'widgets/session_finish_dialog.dart';

/// หน้า Timer ของ Session การเรียน
///
/// ดึงสถานะจาก [SessionStore] กลาง (ส่งผ่าน [SessionStoreProvider]) —
/// ทุกวินาที store จะ `notifyListeners()` ทำให้หน้านี้ rebuild และเวลาอัปเดตอัตโนมัติ
///
/// Flow: Running (นับขึ้น) ↔ Paused (หยุดนับ) → Finish → Finish Dialog → กลับ Home
///
/// เป็น StatelessWidget เพราะ state ทั้งหมดอยู่ใน store แล้ว — rebuild ผ่าน InheritedNotifier
class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  Future<void> _finish(BuildContext context) async {
    final store = SessionStoreProvider.of(context);
    final session = store.current;
    if (session == null) {
      Navigator.of(context).pop();
      return;
    }

    // แสดง dialog สรุปผล — ถ้ากด Done ให้ finish แล้วกลับ Home
    final confirmed = await SessionFinishDialog.show(context, session);
    if (confirmed) {
      store.finish();
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = SessionStoreProvider.of(context);

    // กรณีไม่มี session active (แปลก ๆ) → แสดง empty + ปุ่มกลับ
    if (store.current == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study Session')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No active session'),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    final session = store.current!;
    final isRunning = session.status == SessionStatus.running;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.goalTitle),
        // ปุ่มย้อนกลับ → กลับ Home โดย session ยัง active อยู่ใน store
        // (Home จะแสดง ActiveSessionCard ให้กลับเข้ามาต่อได้)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              const Spacer(),
              // วงแหวนความคืบหน้า + ตัวเลขเวลาตรงกลาง
              _TimerRing(
                progress: store.progress,
                timeText: SessionFormat.duration(store.elapsedSeconds),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // ป้ายสถานะ
              Text(
                isRunning ? 'Running' : 'Paused',
                style: AppTextStyles.label(context),
              ),
              const SizedBox(height: AppSpacing.sm),
              // เป้าหมายของรอบนี้
              Text(
                'Goal: ${session.targetMinutes} min',
                style: AppTextStyles.body(context),
              ),
              const Spacer(),
              // ปุ่ม Pause/Resume (toggle ตามสถานะ)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isRunning
                      ? () => store.pause()
                      : () => store.resume(),
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                  ),
                  child: Text(isRunning ? 'Pause' : 'Resume'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // ปุ่ม Finish
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _finish(context),
                  style: FilledButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                  ),
                  child: const Text('Finish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// วงแหวนความคืบหน้าพร้อมตัวเลขเวลา (mm:ss) อยู่ตรงกลาง
class _TimerRing extends StatelessWidget {
  const _TimerRing({required this.progress, required this.timeText});

  final double progress;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // วงแหวน progress (determinate — ค่าจาก store.progress 0.0–1.0)
          SizedBox(
            width: 260,
            height: 260,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: theme.colorScheme.primary,
            ),
          ),
          // ตัวเลขเวลาเด่นตรงกลาง
          Text(
            timeText,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
