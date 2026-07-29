/// ตัวคำนวณเลเวล (Level) — pure function ที่ทำหน้าที่คำนวณอย่างเดียว
///
/// แยกออกจาก [ProgressStore] เพื่อให้สูตรเลเวลเปลี่ยนได้ที่เดียว
/// โดยไม่ต้องแตะ Store หรือ UI — เช่นอนาคตอาจเปลี่ยนเป็น exponential/curve
/// แก้แค่ไฟล์นี้
///
/// สูตรเริ่มต้น (Sprint 5): **100 XP ต่อ Level** (linear, ง่ายที่สุด)
/// - Level 1 = 0–99 XP, Level 2 = 100–199 XP, ... Level 10 = 900–999 XP
/// - `level = (totalXp ~/ 100) + 1` (Level เริ่มที่ 1)
class LevelCalculator {
  LevelCalculator._(); // ป้องกันการสร้าง instance

  /// จำนวน XP ต้องสะสมต่อ 1 Level
  static const int xpPerLevel = 100;

  /// คำนวณ Level จาก XP สะสมรวม (`totalXp`)
  ///
  /// - 0 XP → Level 1, 99 → 1, 100 → 2, 199 → 2, 200 → 3, 999 → 10
  /// - ค่าติดลบ → Level 1 (กัน edge case)
  static int fromXp(int totalXp) {
    if (totalXp < 0) return 1;
    return (totalXp ~/ xpPerLevel) + 1;
  }

  /// XP ต่ำสุดที่ทำให้ถึง [level] (inclusive lower bound)
  /// - Level 1 → 0, Level 2 → 100, Level 10 → 900
  static int levelStartXp(int level) {
    if (level < 1) return 0;
    return (level - 1) * xpPerLevel;
  }

  /// XP สูงสุดของ [level] (exclusive upper bound = XP ต้องสะสมเพื่อเลื่อนเลเวลถัดไป)
  /// - Level 1 → 100, Level 2 → 200, Level 10 → 1000
  static int levelEndXp(int level) {
    return levelStartXp(level) + xpPerLevel;
  }

  /// XP ที่สะสม "ในเลเวลปัจจุบัน" (reset ทุก 100) — สำหรับ progress bar
  ///
  /// เช่น totalXp = 130, level = 2 → คืน 30 (130 - 100)
  static int xpIntoCurrentLevel(int totalXp) {
    return totalXp - levelStartXp(fromXp(totalXp));
  }

  /// ความคืบหน้าในเลเวลปัจจุบันเป็นสัดส่วน 0.0–1.0 — สำหรับ progress bar
  ///
  /// เช่น totalXp = 130 → 30/100 = 0.30
  static double progressIntoCurrentLevel(int totalXp) {
    return xpIntoCurrentLevel(totalXp) / xpPerLevel;
  }
}
