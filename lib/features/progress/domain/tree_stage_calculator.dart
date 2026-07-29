import 'tree_stage.dart';

/// ตัวคำนวณระยะต้นไม้ (TreeStage) จาก Level — pure function อย่างเดียว
///
/// แยกออกจาก [ProgressStore]/Widget เพื่อให้เกณฑ์การเติบโตเปลี่ยนได้ที่เดียว
/// (เช่นอนาคตเพิ่มระยะใหม่/เปลี่ยนเลเวลที่เปลี่ยนระยะ) แก้แค่ไฟล์นี้
///
/// Tree โตจาก Level (ไม่ใช่เวลา) — ตามข้อกำหนด Sprint 5:
///  - Level 1  → Seed
///  - Level 2  → Sprout
///  - Level 3  → Small Plant
///  - Level 5  → Young Tree
///  - Level 8  → Tree
///  - Level 12 → Big Tree
///  (ค่าระหว่างช่วงใช้ระยะล่าสุดที่ผ่านเกณฑ์ เช่น Level 4 → Small Plant,
///   Level 10 → Tree)
class TreeStageCalculator {
  TreeStageCalculator._(); // ป้องกันการสร้าง instance

  /// คำนวณ [TreeStage] จาก [level]
  ///
  /// เลือกระยะล่าสุดที่ `level >= เกณฑ์` — ถ้ายังไม่ถึงเกณฑ์แรก (Level 1) → seed
  static TreeStage fromLevel(int level) {
    if (level >= 12) return TreeStage.bigTree;
    if (level >= 8) return TreeStage.tree;
    if (level >= 5) return TreeStage.youngTree;
    if (level >= 3) return TreeStage.smallPlant;
    if (level >= 2) return TreeStage.sprout;
    return TreeStage.seed; // Level 1 หรือต่ำกว่า
  }
}
