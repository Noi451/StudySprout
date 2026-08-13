import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// พื้นที่แสดง preview รูปหลักฐาน — **presentation contract**
///
/// Sprint 9A: ไม่มี image picker (ห้ามเพิ่ม package) → รูปมาจาก callback ของ page
/// ตัวนี้แค่แสดง preview เมื่อมี bytes + placeholder เมื่อยังไม่มี
///
/// รองรับทั้งกรณี bytes ว่าง → ถือว่าไม่มีรูป (แสดง placeholder)
class EvidencePreview extends StatelessWidget {
  const EvidencePreview({
    super.key,
    required this.imageBytes,
    required this.onChooseEvidence,
    required this.onReplaceEvidence,
  });

  /// bytes ของรูป (null/empty = ยังไม่มี → แสดง empty state)
  final List<int>? imageBytes;

  /// callback เมื่อแตะเพื่อเลือกรูป (Sprint 9B เสียบ picker)
  final VoidCallback onChooseEvidence;

  /// callback เมื่อแตะเพื่อเปลี่ยนรูป (มีรูปอยู่แล้ว)
  final VoidCallback onReplaceEvidence;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBytes != null && imageBytes!.isNotEmpty;

    return AppSurfaceBox(
      // พื้นที่ preview ต้องมีความสูงจำกัด (aspect ratio) เพื่อทำงานใน ListView
      child: hasImage
          ? _PreviewImage(
              bytes: imageBytes!,
              onReplace: onReplaceEvidence,
            )
          : _EmptyPreview(onChoose: onChooseEvidence),
    );
  }
}

/// Container พื้นผิวรอบ preview — โทน surfaceHigh + border + โค้ง
/// ใช้ AspectRatio (4:3) เพื่อให้ทำงานใน unbounded scroll ได้โดยไม่ overflow
class AppSurfaceBox extends StatelessWidget {
  const AppSurfaceBox({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outlineSoft, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: child,
        ),
      ),
    );
  }
}

/// Empty preview — icon + ข้อความ + ปุ่มเลือกรูป (intentional empty state)
/// อยู่ใน AspectRatio จึงใช้ Center + Column ที่จำกัดความสูงได้
class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview({required this.onChoose});
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChoose,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.emerald.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  color: AppColors.emerald,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Add study evidence',
                style: AppTextStyles.cardTitle(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Take or choose a photo that shows what you worked on.',
                style: AppTextStyles.body(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Preview รูปจริง — แสดง Image.memory + ปุ่ม Replace ลอย
class _PreviewImage extends StatelessWidget {
  const _PreviewImage({required this.bytes, required this.onReplace});
  final List<int> bytes;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // preview เต็มพื้นที่ (AppSurfaceBox ครอบ AspectRatio อยู่แล้ว)
        Image.memory(
          Uint8List.fromList(bytes),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => const _BrokenImage(),
        ),
        // ปุ่ม Replace ลอยมุมขวาบน
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.sm,
          child: _ReplaceChip(onReplace: onReplace),
        ),
      ],
    );
  }
}

class _ReplaceChip extends StatelessWidget {
  const _ReplaceChip({required this.onReplace});
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHighest.withValues(alpha: 0.92),
      borderRadius: AppRadius.pill,
      child: InkWell(
        borderRadius: AppRadius.pill,
        onTap: onReplace,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_horiz, color: AppColors.emerald, size: 16),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Replace',
                style: TextStyle(
                  color: AppColors.emerald,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrokenImage extends StatelessWidget {
  const _BrokenImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined,
                color: AppColors.textMuted, size: 40),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Couldn’t show this image',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
