import 'package:flutter/material.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_press_button.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../core/format/duration_formatter.dart';
import '../../progress/domain/progress_store_provider.dart';
import '../domain/finish_session_service.dart';
import '../domain/session_status.dart';
import '../domain/session_store_provider.dart';
import 'session_format.dart';
import 'widgets/early_finish_dialog.dart';
import 'widgets/session_finish_dialog.dart';

/// หน้า Timer ของ Session การเรียน (Midnight Greenhouse redesign)
///
/// เวลาเป็น focal point; goal title = supporting; circular progress = emerald/sky;
/// Pause = subtle, Finish = danger/subtle (ไม่เด่นเท่า Primary ยกเว้นครบเป้า → primary)
///
/// Business logic (Finish flow / Early Finish / commit) ไม่เปลี่ยนเลย
class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  bool _isFinishing = false;

  Future<void> _finish() async {
    if (_isFinishing) return;

    final sessionStore = SessionStoreProvider.of(context);
    final progressStore = ProgressStoreProvider.of(context);
    final navigator = Navigator.of(context);

    if (!sessionStore.isGoalReached) {
      final confirmed = await EarlyFinishDialog.show(context);
      if (!mounted) return;
      if (!confirmed) return;
    }

    setState(() => _isFinishing = true);

    final result = const FinishSessionService().commit(sessionStore, progressStore);

    if (!mounted) return;
    if (result == null) {
      navigator.pop();
      return;
    }

    await SessionFinishDialog.show(context, result);
    if (!mounted) return;
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = SessionStoreProvider.of(context);

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
    final reached = store.isGoalReached;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(session.goalTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ResponsivePageFrame(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xxl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // focal: time ring
                    _TimerRing(
                      progress: store.progress,
                      timeText: SessionFormat.duration(store.elapsedSeconds),
                      reached: reached,
                      reduceMotion: reduceMotion,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    // status pill
                    StatusPill(
                      label: isRunning ? 'Running' : 'Paused',
                      accent: isRunning ? AppColors.emerald : AppColors.amber,
                      icon: isRunning ? Icons.play_arrow : Icons.pause,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // supporting: goal target
                    Text(
                      'Goal: ${DurationFormatter.fromMinutes(session.targetMinutes)}',
                      style: AppTextStyles.body(context),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    // pause = subtle
                    _PauseResumeButton(
                      isRunning: isRunning,
                      onPause: store.pause,
                      onResume: store.resume,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // finish: danger/subtle (ครบเป้า → primary เด่น)
                    AppPressButton(
                      label: 'Finish',
                      onPressed: _isFinishing ? null : _finish,
                      variant: reached ? AppButtonVariant.primary : AppButtonVariant.subtle,
                      icon: Icons.check,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ปุ่ม Pause/Resume — subtle (surface) เปลี่ยนสี animated
class _PauseResumeButton extends StatelessWidget {
  const _PauseResumeButton({
    required this.isRunning,
    required this.onPause,
    required this.onResume,
  });

  final bool isRunning;
  final VoidCallback onPause;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.easeOutCubic,
        decoration: BoxDecoration(
          color: isRunning ? AppColors.surfaceHigh : AppColors.emeraldContainer,
          borderRadius: AppRadius.button,
          border: Border.all(
            color: isRunning ? AppColors.outlineSoft : AppColors.emerald.withValues(alpha: 0.4),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.button,
            onTap: isRunning ? onPause : onResume,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: AnimatedSwitcher(
                  duration: AppMotion.short,
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    isRunning ? 'Pause' : 'Resume',
                    key: ValueKey(isRunning),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isRunning ? AppColors.textPrimary : AppColors.emerald,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// วงแหวนเวลา — focal point; emerald ring, sky เมื่อครบเป้า
class _TimerRing extends StatelessWidget {
  const _TimerRing({
    required this.progress,
    required this.timeText,
    required this.reached,
    required this.reduceMotion,
  });

  final double progress;
  final String timeText;
  final bool reached;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final ringColor = reached ? AppColors.sky : AppColors.emerald;

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 14,
              backgroundColor: AppColors.surfaceHighest,
              color: ringColor,
              strokeCap: StrokeCap.round,
            ),
          ),
          AnimatedSwitcher(
            duration: reduceMotion ? Duration.zero : AppMotion.short,
            transitionBuilder: (child, animation) {
              if (reduceMotion) return child;
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.90, end: 1.00).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              timeText,
              key: ValueKey(timeText),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 52,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
