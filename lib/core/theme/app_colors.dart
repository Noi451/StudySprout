import 'package:flutter/material.dart';

/// ชุดสี (Design System) ของแอป StudySprout
///
/// รวมสี "หลัก" ที่ใช้ซ้ำทั่วทั้งแอปไว้ที่เดียว เพื่อให้:
///  - ปรับสีได้ที่เดียว แล้วเปลี่ยนทั้งแอป
///  - ไม่มี "magic color" กระจัดกระจายในโค้ด
///
/// หมายเหตุ: สีที่อนุพันธ์จาก [ColorScheme] (primary/onSurface ฯลฯ) ยังใช้ผ่าน
/// `Theme.of(context).colorScheme` ตามปกติ — ไฟล์นี้เก็บเฉพาะสีคงที่ที่
/// ไม่ได้อยู่ใน ColorScheme เช่น สีไฟ streak หรือสีพื้นหลังวงกลมต้นไม้
class AppColors {
  AppColors._(); // ป้องกันการสร้าง instance — ใช้แค่ static constant

  /// สีเมล็ดพันธุ์ (seed) สำหรับสร้าง ColorScheme — เขียวเข้ม สื่อ "การเติบโต/การเรียน"
  static const Color seed = Color(0xFF2E7D32);

  /// สีไฟ (flame) สำหรับ streak — ส้มอ่อน ดูอบอุ่น
  static const Color flame = Color(0xFFFF6F00);

  /// สีพื้นหลังวงกลมรอบต้นไม้ — เขียวอ่อนโปร่งแสง นุ่มนวล
  static const Color treeHalo = Color(0x1A4CAF50);

  /// สีพื้นหลังการ์ดเป้าหมายในสถานะว่าง — เทาอ่อนมาก ใกล้พื้นหลัง
  static const Color emptyGoalSurface = Color(0xFFF5F7F5);
}
