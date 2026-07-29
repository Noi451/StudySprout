import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'level_calculator.dart';
import 'tree_stage.dart';
import 'tree_stage_calculator.dart';

/// ที่เก็บ "ความคืบหน่าน XP/Level" ของทั้งแอป — สำหรับระบบ Gamification
///
/// เป็น [ChangeNotifier] เพื่อให้ widget ที่ฟัง (เช่น XpCard/TreeSection บน Home)
/// rebuild อัตโนมัติเมื่อ XP/Level เปลี่ยน (หลัง Finish Session)
///
/// ตัวนี้เป็น "state" ล้วน ๆ — **ไม่คำนวณกฎ XP/Level/TreeStage เอง**
/// แต่เรียกใช้ pure calculator แยกไฟล์ ([XpCalculator]/[LevelCalculator]/
/// [TreeStageCalculator]) เพื่อให้เปลี่ยนกฎได้ที่เดียว (Separation of Concerns)
///
/// Sprint 5:
///  - **XP**: รับ XP ผ่าน [addXp] (UI/Timer เป็นคนคำนวณด้วย [XpCalculator] แล้วส่งมา)
///  - **Level**: คำนวณจาก totalXp ผ่าน [LevelCalculator] (ไม่เก็บ level ตรง ๆ
///    แต่เก็บ totalXp แล้ว derive — กันความไม่สอดคล้องกัน)
///  - **Tree Stage**: derive จาก level ผ่าน [TreeStageCalculator] (ไม่เก็บแยก)
///  - **Persistence**: บันทึก/กู้คืน totalXp (level คำนวณใหม่ได้จาก totalXp)
///
/// Storage keys (SharedPreferences):
///  - `progress_total_xp`  int — XP สะสมรวม (Level derive จากตัวนี้)
class ProgressStore extends ChangeNotifier {
  ProgressStore();

  int _totalXp = 0;

  /// XP สะสมรวม (อ่านได้อย่างเดียวจากภายนอก)
  int get totalXp => _totalXp;

  /// XP ที่สะสม "ในเลเวลปัจจุบัน" (reset ทุก 100) — สำหรับ progress bar
  ///
  /// เช่น totalXp = 130, level = 2 → 30
  int get currentLevelXp => LevelCalculator.xpIntoCurrentLevel(_totalXp);

  /// XP ต้องสะสมเพื่อเลื่อนเลเวลถัดไป (lower bound ของเลเวลถัดไป)
  /// เช่น level = 2 → 200 (ใช้แสดง "30 / 100" เมื่อหัก levelStartXp ออก)
  int get currentLevelEndXp => LevelCalculator.xpPerLevel;

  /// Level ปัจจุบัน — derive จาก totalXp
  int get level => LevelCalculator.fromXp(_totalXp);

  /// ระยะต้นไม้ปัจจุบัน — derive จาก level
  TreeStage get treeStage => TreeStageCalculator.fromLevel(level);

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// เพิ่ม XP (`xp` ต้องคำนวณโดย [XpCalculator] ก่อนส่งมา) แล้วแจ้ง listener
  ///
  /// เก็บเป็น totalXp — level/treeStage derive อัตโนมัติ (คืนค่าเดิมถ้า xp <= 0)
  void addXp(int xp) {
    if (xp <= 0) return;
    _totalXp += xp;
    _persist();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Persistence (SharedPreferences)
  // ---------------------------------------------------------------------------

  /// คีย์ SharedPreferences
  static const String totalXpKey = 'progress_total_xp';

  /// กู้คืน totalXp จาก SharedPreferences — เรียกตอนเปิดแอป (ก่อน runApp)
  ///
  /// level/treeStage derive จาก totalXp ที่กู้คืนได้ จึงกลับมาถูกต้องหลังเปิดแอปใหม่
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _totalXp = prefs.getInt(totalXpKey) ?? 0;
    notifyListeners();
  }

  /// บันทึก totalXp ลง SharedPreferences (fire-and-forget เหมือน GoalStore)
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(totalXpKey, _totalXp);
  }

  /// (ใช้ใน test เท่านั้น) รีเซ็ต state กลับเป็น 0
  @visibleForTesting
  void reset() {
    _totalXp = 0;
    notifyListeners();
  }
}
