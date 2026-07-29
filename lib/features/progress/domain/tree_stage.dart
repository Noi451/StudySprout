/// ระยะการเติบโตของต้นไม้ — เปลี่ยนตาม Level (ไม่ใช่ตามเวลา)
///
/// Sprint 5: ใช้ enum + helper คำนวณจาก Level ห้าม hardcode ใน Widget
/// ยังไม่ใช้รูปใหม่ — แต่ละ stage มี label/emoji/icon ให้ UI ใช้แสดงผล
///
/// ระยะตามข้อกำหนด:
///  - Level 1  → Seed         🌱
///  - Level 2  → Sprout       🌿
///  - Level 3  → Small Plant  🌱
///  - Level 5  → Young Tree   🌳
///  - Level 8  → Tree         🌳
///  - Level 12 → Big Tree     🌳
enum TreeStage {
  seed('Seed', '🌱'),
  sprout('Sprout', '🌿'),
  smallPlant('Small Plant', '🌱'),
  youngTree('Young Tree', '🌳'),
  tree('Tree', '🌳'),
  bigTree('Big Tree', '🌳');

  const TreeStage(this.label, this.emoji);

  /// ชื่อระยะ (สำหรับแสดงใน UI)
  final String label;

  /// อิโมจิประกอบ (Sprint 5 ยังไม่มีรูปจริง — ใช้อิโมจิแทนชั่วคราว)
  final String emoji;
}
