import 'package:flutter/material.dart';

/// ชุดค่าความโค้ง (border radius) ของ Design System StudySprout
///
/// ทำให้ความโค้งของทุกองค์ประกอบในแอปมาจากที่เดียว — ปรับที่นี่เปลี่ยนทั้งแอป
/// และกำจัด magic number เช่น `BorderRadius.circular(16)` ที่กระจัดกระจาย
///
/// ตัวอย่าง:
/// ```
/// borderRadius: AppRadius.lg   // แทน BorderRadius.circular(16)
/// shape: RoundedRectangleBorder(borderRadius: AppRadius.button) // ปุ่ม
/// ```
class AppRadius {
  AppRadius._(); // ป้องกันการสร้าง instance

  /// 8 px — มุมโค้งเล็ก (การ์ดสถิติ, chip)
  static const double sm = 8;

  /// 12 px — มุมโค้งกลาง
  static const double md = 12;

  /// 16 px — มุมโค้งมาตรฐานของการ์ดและปุ่มใหญ่
  static const double lg = 16;

  /// 20 px — มุมโค้งใหญ่ (คอนเทนเนอร์เด่น ๆ)
  static const double xl = 20;

  /// มุมโค้งของปุ่มใหญ่ (CTA) — โค้งนุ่มนวล
  static const BorderRadius button = BorderRadius.all(Radius.circular(lg));

  /// มุมโค้งของการ์ดทั่วไป
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));

  /// มุมโค้งของวงกลมพื้นหลังต้นไม้ (ใช้ค่ากลางล้อมใน [Radius.circular])
  static const double treeHalo = 120;
}
