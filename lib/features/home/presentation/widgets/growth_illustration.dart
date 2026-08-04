import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../progress/domain/tree_stage.dart';

/// ภาพประกอบ "ต้นไม้โต" แบบ vector — วาดด้วย CustomPainter (Flutter SDK ล้วน)
///
/// Sprint 8 PART 4: Material Icon ไม่พอสำหรับ Hero → สร้าง illustration จริง
/// แต่ละ [TreeStage] มี silhouette ต่างกัน (ไม่ใช่แค่เปลี่ยน icon)
///
/// Stages (ตาม enum จริง):
///  - seed       เมล็ดในดิน + glow เบา
///  - sprout     ลำต้นสั้น + ใบ 2 ใบ
///  - smallPlant สูงขึ้น + ใบหลายใบ
///  - youngTree  ลำต้น + พุ่มใบชัด
///  - tree       ลำต้นใหญ่ + พุ่มกลมใหญ่
///  - bigTree    พุ่มใหญ่มาก + ราก
///
/// ไม่มี animation loop ต่อเนื่อง (กันกินทรัพยากร) — มีแค่ transition ตอนเปลี่ยน stage
/// เคารพ reduceMotion (duration เป็น Duration.zero)
class GrowthIllustration extends StatelessWidget {
  const GrowthIllustration({
    required this.stage,
    super.key,
    this.size = 190,
    this.withHalo = true,
  });

  final TreeStage stage;
  final double size;

  /// วงกลม halo โทนเขียวโปร่งหลังต้นไม้ (Hero)
  final bool withHalo;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (withHalo)
            Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: AppColors.treeHalo,
                shape: BoxShape.circle,
              ),
            ),
          AnimatedSwitcher(
            duration: reduceMotion ? Duration.zero : AppMotion.slow,
            switchInCurve: AppMotion.emphasized,
            switchOutCurve: AppMotion.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: SizedBox.square(
              key: ValueKey(stage),
              dimension: size,
              child: CustomPaint(
                painter: GrowthPainter(
                  stage: stage,
                  primary: AppColors.emerald,
                  secondary: AppColors.sky,
                  soil: AppColors.amberContainer,
                  stem: AppColors.emeraldContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter ของต้นไม้ — วาดรูปทรงตาม [TreeStage] บน Canvas
class GrowthPainter extends CustomPainter {
  GrowthPainter({
    required this.stage,
    required this.primary,
    required this.secondary,
    required this.soil,
    required this.stem,
  });

  final TreeStage stage;
  final Color primary;
  final Color secondary;
  final Color soil;
  final Color stem;

  /// size ปัจจุบัน (ตั้งตอนเริ่ม paint ใช้ใน helper)
  double _s = 0;

  @override
  void paint(Canvas canvas, Size size) {
    _s = size.width;
    final s = _s;
    final cx = s / 2;
    final groundY = s * 0.80;

    _drawSoil(canvas, cx, groundY);

    switch (stage) {
      case TreeStage.seed:
        _drawSeed(canvas, cx, groundY);
      case TreeStage.sprout:
        _drawSprout(canvas, cx, groundY);
      case TreeStage.smallPlant:
        _drawSmallPlant(canvas, cx, groundY);
      case TreeStage.youngTree:
        _drawYoungTree(canvas, cx, groundY);
      case TreeStage.tree:
        _drawTree(canvas, cx, groundY);
      case TreeStage.bigTree:
        _drawBigTree(canvas, cx, groundY);
    }
  }

  // --- ดิน (เนินเล็กที่โคน) ---
  void _drawSoil(Canvas canvas, double cx, double groundY) {
    final r = _s * 0.13;
    final paint = Paint()..color = soil;
    final path = Path()
      ..moveTo(cx - r, groundY)
      ..quadraticBezierTo(cx, groundY - r * 0.5, cx + r, groundY)
      ..quadraticBezierTo(cx, groundY + r * 0.18, cx - r, groundY)
      ..close();
    canvas.drawPath(path, paint);
  }

  // --- เมล็ด + glow ---
  void _drawSeed(Canvas canvas, double cx, double groundY) {
    final glow = Paint()
      ..color = primary.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(Offset(cx, groundY - _s * 0.04), _s * 0.07, glow);

    final paint = Paint()..color = primary;
    final r = _s * 0.05;
    final path = Path()
      ..moveTo(cx, groundY - r * 2.2)
      ..quadraticBezierTo(cx + r, groundY - r, cx, groundY)
      ..quadraticBezierTo(cx - r, groundY - r, cx, groundY - r * 2.2)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(cx, groundY - r * 2.2), r * 0.4, paint);
  }

  // --- ลำต้นสั้น + ใบ 2 ใบ ---
  void _drawSprout(Canvas canvas, double cx, double groundY) {
    final stemH = _s * 0.18;
    _drawStem(canvas, cx, groundY, stemH, _s * 0.012);
    final topY = groundY - stemH;
    _drawLeaf(canvas, Offset(cx, topY + _s * 0.02), -1, _s * 0.075);
    _drawLeaf(canvas, Offset(cx, topY + _s * 0.02), 1, _s * 0.075);
    canvas.drawCircle(Offset(cx, topY - _s * 0.01), _s * 0.012, Paint()..color = primary);
  }

  // --- สูงขึ้น + ใบหลายใบ ---
  void _drawSmallPlant(Canvas canvas, double cx, double groundY) {
    final stemH = _s * 0.28;
    _drawStem(canvas, cx, groundY, stemH, _s * 0.014);
    for (var i = 0; i < 3; i++) {
      final y = groundY - stemH * (0.25 + i * 0.28);
      final scale = 1.0 - i * 0.18;
      _drawLeaf(canvas, Offset(cx, y), -1, _s * 0.07 * scale);
      _drawLeaf(canvas, Offset(cx, y), 1, _s * 0.07 * scale);
    }
    canvas.drawCircle(Offset(cx, groundY - stemH), _s * 0.016, Paint()..color = primary);
  }

  // --- ลำต้น + พุ่มใบชัด ---
  void _drawYoungTree(Canvas canvas, double cx, double groundY) {
    final stemH = _s * 0.36;
    _drawStem(canvas, cx, groundY, stemH, _s * 0.02);
    final crownY = groundY - stemH;
    _drawBlob(canvas, Offset(cx, crownY), _s * 0.13);
    _drawBlob(canvas, Offset(cx - _s * 0.08, crownY + _s * 0.04), _s * 0.10);
    _drawBlob(canvas, Offset(cx + _s * 0.08, crownY + _s * 0.04), _s * 0.10);
    _drawBlob(canvas, Offset(cx, crownY - _s * 0.02), _s * 0.07, secondary.withValues(alpha: 0.5));
  }

  // --- ลำต้นใหญ่ + พุ่มกลมใหญ่ ---
  void _drawTree(Canvas canvas, double cx, double groundY) {
    final stemH = _s * 0.42;
    _drawStem(canvas, cx, groundY, stemH, _s * 0.028);
    final crownY = groundY - stemH;
    _drawBlob(canvas, Offset(cx, crownY), _s * 0.18);
    _drawBlob(canvas, Offset(cx - _s * 0.12, crownY + _s * 0.05), _s * 0.13);
    _drawBlob(canvas, Offset(cx + _s * 0.12, crownY + _s * 0.05), _s * 0.13);
    _drawBlob(canvas, Offset(cx, crownY - _s * 0.08), _s * 0.12);
    _drawBlob(canvas, Offset(cx + _s * 0.05, crownY - _s * 0.04), _s * 0.06, secondary.withValues(alpha: 0.45));
  }

  // --- พุ่มใหญ่มาก + ราก ---
  void _drawBigTree(Canvas canvas, double cx, double groundY) {
    final stemH = _s * 0.44;
    _drawStem(canvas, cx, groundY, stemH, _s * 0.034, withRoots: true);
    final crownY = groundY - stemH;
    _drawBlob(canvas, Offset(cx, crownY), _s * 0.22);
    _drawBlob(canvas, Offset(cx - _s * 0.15, crownY + _s * 0.06), _s * 0.16);
    _drawBlob(canvas, Offset(cx + _s * 0.15, crownY + _s * 0.06), _s * 0.16);
    _drawBlob(canvas, Offset(cx, crownY - _s * 0.10), _s * 0.15);
    _drawBlob(canvas, Offset(cx - _s * 0.09, crownY - _s * 0.06), _s * 0.12);
    _drawBlob(canvas, Offset(cx + _s * 0.09, crownY - _s * 0.06), _s * 0.12);
    _drawBlob(canvas, Offset(cx + _s * 0.06, crownY - _s * 0.05), _s * 0.08, secondary.withValues(alpha: 0.4));
  }

  // --- primitives ---

  void _drawStem(
    Canvas canvas,
    double cx,
    double groundY,
    double height,
    double width, {
    bool withRoots = false,
  }) {
    final paint = Paint()..color = stem;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, groundY - height / 2),
        width: width,
        height: height,
      ),
      Radius.circular(width / 2),
    );
    canvas.drawRRect(rect, paint);

    if (withRoots) {
      final rootPaint = Paint()
        ..color = stem
        ..strokeWidth = width * 0.7
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx, groundY),
        Offset(cx - _s * 0.05, groundY + _s * 0.02),
        rootPaint,
      );
      canvas.drawLine(
        Offset(cx, groundY),
        Offset(cx + _s * 0.05, groundY + _s * 0.02),
        rootPaint,
      );
    }
  }

  void _drawLeaf(Canvas canvas, Offset base, int dir, double len) {
    final paint = Paint()..color = primary;
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx + dir * len * 0.8,
        base.dy - len * 0.2,
        base.dx + dir * len,
        base.dy - len * 0.5,
      )
      ..quadraticBezierTo(
        base.dx + dir * len * 0.6,
        base.dy + len * 0.1,
        base.dx,
        base.dy,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawBlob(Canvas canvas, Offset center, double r, [Color? color]) {
    final paint = Paint()..color = color ?? primary;
    canvas.drawCircle(center, r, paint);
  }

  @override
  bool shouldRepaint(covariant GrowthPainter old) =>
      old.stage != stage ||
      old.primary != primary ||
      old.secondary != secondary ||
      old.soil != soil ||
      old.stem != stem;
}
