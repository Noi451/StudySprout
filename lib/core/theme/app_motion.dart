import 'package:flutter/animation.dart';

/// Motion Design tokens ของ StudySprout (Midnight Greenhouse)
///
/// รวม durations + curves ไว้ที่เดียว กัน magic duration กระจาย
/// ทุกแอนิเมชันใช้ curve ชุดเดียวกัน → ดูเป็น "ระบบเดียว"
class AppMotion {
  AppMotion._();

  // --- Durations ---

  /// 600 ms — entrance ใหญ่ (Hero, Tree entrance)
  static const Duration entrance = Duration(milliseconds: 600);

  /// 800 ms — entrance ช้าสุด (Growth Hero บางส่วน)
  static const Duration slow = Duration(milliseconds: 800);

  /// 300 ms — transition กลาง (stage change, badge, button color)
  static const Duration medium = Duration(milliseconds: 300);

  /// 200 ms — transition สั้น (label fade, stagger step base, timer digit)
  static const Duration short = Duration(milliseconds: 200);

  /// 400 ms — XP/progress bar tween
  static const Duration bar = Duration(milliseconds: 400);

  /// 50 ms — หน่วง stagger (Progress stat cards) ต่อ index
  static const int staggerStepMs = 50;

  // --- Curves ---

  /// easeOutCubic — calm/organic (entrance + transition ส่วนใหญ่)
  static const Curve easeOutCubic = Curves.easeOutCubic;

  /// easeInOutCubic — transition กลับกลับได้ (ปุ่มกด-ปล่อย)
  static const Curve easeInOutCubic = Curves.easeInOutCubic;

  /// emphasized — stage change / hero (สั้น โดด เล็กน้อย)
  static const Curve emphasized = Curves.easeOutBack;

  /// bounceOut — icon nav เด้งเล็กน้อย
  static const Curve bounceOut = Curves.easeOutBack;

  /// easeIn — exit (stage ออก)
  static const Curve easeIn = Curves.easeIn;
}
