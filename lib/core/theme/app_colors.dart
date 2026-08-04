import 'package:flutter/material.dart';

/// ชุดสี (Design Tokens) ของ StudySprout — ทิศทาง "Midnight Greenhouse"
///
/// Sprint 8: เปลี่ยนจาก Light theme เป็น **Dark-first Product Design**
/// สีทั้งหมดเป็น **semantic roles** ไม่ใช่ชื่อตามตำแหน่ง (ไม่มี card1Color/card2Color)
///
/// โทนหลัก:
///  - **Midnight Navy** เป็นพื้นหลัง (`background`/`backgroundSoft`)
///  - **Deep Slate** เป็นพื้นผิว 3 ระดับ (`surface`/`surfaceHigh`/`surfaceHighest`)
///  - **Emerald** เป็นสีแบรนด์ + Primary Action
///  - **Sky Blue** ใช้กับข้อมูลเวลา/Progress (secondary)
///  - **Amber** ใช้กับ Streak/Achievement (tertiary)
///  - **Danger** ใช้เฉพาะ destructive/error
///
/// ตัวอักษร 3 ระดับ: `textPrimary` / `textSecondary` / `textMuted`
/// (contrast ปกติ ≥ WCAG AA; textMuted ใช้เฉพาะ metadata/caption)
abstract final class AppColors {
  // --- Background (Midnight Navy) ---
  static const background = Color(0xFF07131F);
  static const backgroundSoft = Color(0xFF0A1826);

  // --- Surface (Deep Slate, 3 ระดับ) ---
  static const surface = Color(0xFF0E2032);
  static const surfaceHigh = Color(0xFF162A40);
  static const surfaceHighest = Color(0xFF1D344C);

  // --- Outline ---
  static const outline = Color(0xFF294158);
  static const outlineSoft = Color(0xFF1C3145);

  // --- Emerald (Primary / brand / growth) ---
  static const emerald = Color(0xFF3DDB9A);
  static const emeraldContainer = Color(0xFF123D32);
  static const onEmerald = Color(0xFF031C14);

  // --- Sky (Secondary / time / progress) ---
  static const sky = Color(0xFF55B9FF);
  static const skyContainer = Color(0xFF12334D);

  // --- Amber (Tertiary / streak / achievement) ---
  static const amber = Color(0xFFFFB65C);
  static const amberContainer = Color(0xFF493018);

  // --- Danger (destructive / error เท่านั้น) ---
  static const danger = Color(0xFFFF7070);

  // --- Text roles ---
  static const textPrimary = Color(0xFFF3F8F7);
  static const textSecondary = Color(0xFFA9B8C4);
  static const textMuted = Color(0xFF718597);

  // --- Semantic helpers สำหรับ accent role ---
  /// สี accent ตามบทบาท (สำหรับ MetricTile/StatusPill) — ไม่ใช่ตกแต่ง
  static const Color growth = emerald; // ต้นไม้/Level/โต
  static const Color time = sky; // เวลา/progress ข้อมูล
  static const Color streak = amber; // streak/achievement (ใช้เฉพาะมีข้อมูลจริง)

  // --- ค่าดั้งเดิมที่ยังจำเป็น (compat) ---
  // treeHalo: วงกลมโทนเขียวโปร่งหลังต้นไม้ (ใช้ใน GrowthIllustration/Hero)
  static const treeHalo = Color(0x1A3DDB9A);
}
