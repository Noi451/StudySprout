import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_press_button.dart';
import '../../../../core/widgets/app_surface.dart';
import '../domain/evidence_verification_store_provider.dart';
import '../domain/evidence_verification_status.dart';
import '../domain/verification_result.dart';
import 'evidence_preview.dart';

/// หน้าทดลอง "Study Evidence Verification" — Sprint 9A foundation
///
/// **ยังไม่เชื่อม Finish Flow** — เป็น feature แยกให้พร้อมสำหรับ Sprint 9B/9C
/// ห้าม commit session / แจก XP ในหน้านี้ (PART 10)
///
/// UI states (PART 5):
///  - idle: empty state + Verify disabled
///  - verifying: loading + disabled (ป้องกัน double submit)
///  - passed: success visual + reason (confidence optional)
///  - rejected: reject + reason + Try Another Evidence
///  - error: error + retry ไม่ crash
///
/// Image picker ผ่าน callback [onChooseEvidence] (Sprint 9B เสียบ picker จริง)
/// ใช้ Midnight Greenhouse theme เดิม + ResponsivePageFrame
class EvidenceVerificationPage extends StatelessWidget {
  const EvidenceVerificationPage({
    super.key,
    required this.goalTitle,
    required this.onChooseEvidence,
  });

  /// ชื่อเป้าหมายที่กำลังตรวจหลักฐานให้
  final String goalTitle;

  /// callback เมื่อแตะเพื่อเลือก/เปลี่ยนรูป (Sprint 9B เสียบ image picker)
  final VoidCallback onChooseEvidence;

  @override
  Widget build(BuildContext context) {
    final store = EvidenceVerificationStoreProvider.of(context);
    final status = store.status;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Study Evidence'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ResponsivePageFrame(
          // SingleChildScrollView (ไม่ใช่ ListView) เพื่อให้ทุก widget ถูก build
          // หลังจาก layout settle — กันปุ่มหลุดจาก viewport ตอน test/compact ที่
          // preview อาจกินความสูงเยอะ และทำให้ find ไม่เจอ
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: AppSpacing.xl,
              bottom: AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Goal context
                _GoalContext(goalTitle: goalTitle),
                const SizedBox(height: AppSpacing.xl),

                // Evidence area
                EvidencePreview(
                  imageBytes: store.imageBytes,
                  onChooseEvidence: onChooseEvidence,
                  onReplaceEvidence: onChooseEvidence,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Status feedback (verifying/passed/rejected/error)
                _StatusFeedback(status: status, result: store.result),
                if (status != EvidenceVerificationStatus.idle)
                  const SizedBox(height: AppSpacing.lg),

                // Primary action
                _PrimaryAction(
                  status: status,
                  hasEvidence: store.hasEvidence,
                  onVerify: () => store.verify(goalTitle: goalTitle),
                  onRetry: store.reset,
                  onTryAnother: onChooseEvidence,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Goal context — "Evidence for ... "
class _GoalContext extends StatelessWidget {
  const _GoalContext({required this.goalTitle});
  final String goalTitle;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      level: AppSurfaceLevel.base,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            const Icon(Icons.flag, color: AppColors.emerald, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Evidence for', style: AppTextStyles.metricLabel(context)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '"$goalTitle"',
                    style: AppTextStyles.cardTitle(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// แสดงผลตาม status — verifying/passed/rejected/error (idle ไม่แสดง)
class _StatusFeedback extends StatelessWidget {
  const _StatusFeedback({required this.status, required this.result});
  final EvidenceVerificationStatus status;
  final VerificationResult? result;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case EvidenceVerificationStatus.idle:
        return const SizedBox.shrink();
      case EvidenceVerificationStatus.verifying:
        return const _StatusPanel(
          accent: AppColors.sky,
          icon: Icons.hourglass_top,
          title: 'Checking your evidence…',
          caption: null,
          showSpinner: true,
        );
      case EvidenceVerificationStatus.passed:
        return _StatusPanel(
          accent: AppColors.emerald,
          icon: Icons.check_circle,
          title: 'Evidence verified',
          caption: result?.reason,
          secondary: result != null
              ? 'Confidence ${(result!.confidence * 100).round()}%'
              : null,
        );
      case EvidenceVerificationStatus.rejected:
        return _StatusPanel(
          accent: AppColors.amber,
          icon: Icons.report_problem,
          title: 'Evidence doesn’t match',
          caption: result?.reason,
        );
      case EvidenceVerificationStatus.error:
        return const _StatusPanel(
          accent: AppColors.danger,
          icon: Icons.error_outline,
          title: 'Couldn’t verify evidence',
          caption: 'Please try again.',
        );
    }
  }
}

/// พื้นที่แสดงผลสถานะ — pill + title + caption + (optional spinner/secondary)
class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.accent,
    required this.icon,
    required this.title,
    this.caption,
    this.secondary,
    this.showSpinner = false,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String? caption;
  final String? secondary;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      level: AppSurfaceLevel.high,
      borderOverride: accent.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            if (showSpinner)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: accent,
                ),
              )
            else
              Icon(icon, color: accent, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle(context)),
                  if (caption != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(caption!, style: AppTextStyles.body(context)),
                  ],
                  if (secondary != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(secondary!, style: AppTextStyles.caption(context)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ปุ่มหลักตามสถานะ
class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.status,
    required this.hasEvidence,
    required this.onVerify,
    required this.onRetry,
    required this.onTryAnother,
  });

  final EvidenceVerificationStatus status;
  final bool hasEvidence;
  final VoidCallback onVerify;
  final VoidCallback onRetry;
  final VoidCallback onTryAnother;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case EvidenceVerificationStatus.idle:
        // Verify Evidence — disabled ถ้ายังไม่มี evidence
        return AppPressButton(
          label: 'Verify Evidence',
          onPressed: hasEvidence ? onVerify : null,
          icon: Icons.verified_outlined,
        );
      case EvidenceVerificationStatus.verifying:
        // disabled + ป้องกัน double submit (store guard ด้วย)
        return AppPressButton(
          label: 'Checking…',
          onPressed: null,
          icon: Icons.hourglass_top,
        );
      case EvidenceVerificationStatus.passed:
        // ผ่าน → ไม่ commit อะไร (Sprint 9A) แค่แสดง result; ปุ่มเป็น Done/ปิด
        return AppPressButton(
          label: 'Done',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icons.check,
        );
      case EvidenceVerificationStatus.rejected:
        // ลองหลักฐานใหม่ → กลับไป idle/เลือกใหม่
        return Column(
          children: [
            AppPressButton(
              label: 'Try Another Evidence',
              onPressed: onTryAnother,
              icon: Icons.refresh,
            ),
            const SizedBox(height: AppSpacing.sm),
            // retry verify รูปเดิมได้ (reset กลับ idle)
            TextButton(
              onPressed: onRetry,
              child: const Text('Verify this image again'),
            ),
          ],
        );
      case EvidenceVerificationStatus.error:
        // error → retry verify รูปเดิม หรือเลือกใหม่
        return Column(
          children: [
            AppPressButton(
              label: 'Retry',
              onPressed: onRetry,
              icon: Icons.refresh,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onTryAnother,
              child: const Text('Choose another evidence'),
            ),
          ],
        );
    }
  }
}
