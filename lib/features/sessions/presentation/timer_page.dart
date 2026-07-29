import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/format/duration_formatter.dart';
import '../../progress/domain/progress_store_provider.dart';
import '../domain/finish_session_service.dart';
import '../domain/session_status.dart';
import '../domain/session_store_provider.dart';
import 'session_format.dart';
import 'widgets/session_finish_dialog.dart';

/// หน้า Timer ของ Session การเรียน
///
/// ดึงสถานะจาก [SessionStore] กลาง (ส่งผ่าน [SessionStoreProvider]) —
/// ทุกวินาที store จะ `notifyListeners()` ทำให้หน้านี้ rebuild และเวลาอัปเดตอัตโนมัติ
///
/// Sprint 5.1 — Finish Flow Hardening:
///  - เปลี่ยนเป็น StatefulWidget (กรณีจำเป็นจริง ๆ) เพื่อมี transient guard flag
///  - **commit ก่อนเปิด dialog** ผ่าน [FinishSessionService.commit] (exactly once)
///  - dialog เป็น presentation only — Done แค่ปิด ไม่ trigger การบันทึก
///  - `_isFinishing` guard ป้องกันกด Finish รัว ๆ / re-entry / dialog ซ้อน
///
/// Flow: Running (นับขึ้น) ↔ Paused → Finish → commit → Finish Dialog → กลับ Home
class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  /// guard กันกด Finish รัว ๆ และ re-entry ขณะกำลัง commit/แสดง dialog
  bool _isFinishing = false;

  Future<void> _finish(BuildContext context) async {
    // ป้องกัน re-entry — ถ้ากำลัง finish อยู่แล้ว ไม่ทำซ้ำ
    if (_isFinishing) return;
    setState(() => _isFinishing = true);

    final sessionStore = SessionStoreProvider.of(context);
    final progressStore = ProgressStoreProvider.of(context);
    // จับ Navigator ไว้ก่อน await (context ที่ส่งเข้ามาอาจ stale หลัง async gap)
    final navigator = Navigator.of(context);

    // commit ก่อนเปิด dialog — exactly once (synchronous, atomic)
    // บันทึก history + แจก XP แล้วคืน snapshot ผลลัพธ์ (null = ไม่มี active session)
    final result = const FinishSessionService().commit(
      sessionStore,
      progressStore,
    );

    // หยุดที่นี่ถ้า widget ถูก dispose ระหว่าง commit
    if (!mounted) return;

    // ไม่มี active session → ไม่มีอะไรจะแสดง → pop กลับ
    if (result == null) {
      navigator.pop();
      return;
    }

    // แสดง dialog สรุปผล — presentation only (อ่านจาก snapshot)
    // ปิดด้วยวิธีใดก็ตาม (Done/Back/Escape/กดนอก) ข้อมูล commit ไปแล้ว
    await SessionFinishDialog.show(context, result);

    // ปิด dialog แล้ว → pop กลับ Home (เช็ก mounted หลัง await)
    if (!mounted) return;
    navigator.pop();
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
                'Goal: ${DurationFormatter.fromMinutes(session.targetMinutes)}',
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
              // ปุ่ม Finish — disabled ขณะกำลัง finish (กันกดซ้ำ)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isFinishing ? null : () => _finish(context),
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
