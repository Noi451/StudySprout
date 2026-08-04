import 'package:flutter/material.dart';

/// ชุดค่าความโค้ง (border radius) ของ Design System StudySprout
///
/// ปรับที่นี่ที่เดียว → เปลี่ยนทั้งแอป กำจัด magic number
class AppRadius {
  AppRadius._();

  /// 6 px — มุมโค้งเล็ก (chip, pill ภายใน, icon chip)
  static const double xs = 6;

  /// 8 px — มุมโค้งเล็ก (การ์ดสถิติ, status pill)
  static const double sm = 8;

  /// 12 px — มุมโค้งกลาง
  static const double md = 12;

  /// 16 px — มุมโค้งมาตรฐานของการ์ดและปุ่มใหญ่
  static const double lg = 16;

  /// 20 px — มุมโค้งใหญ่ (Hero card, คอนเทนเนอร์เด่น)
  static const double xl = 20;

  /// 28 px — มุมโค้งใหญ่พิเศษ (Hero card บางจุด)
  static const double xxl = 28;

  /// ปุ่มใหญ่ (CTA) — โค้งนุ่ม
  static const BorderRadius button = BorderRadius.all(Radius.circular(lg));

  /// การ์ดทั่วไป
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));

  /// Hero card — โค้งใหญ่กว่าเด่น
  static const BorderRadius hero = BorderRadius.all(Radius.circular(xl));

  /// pill / chip
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}
