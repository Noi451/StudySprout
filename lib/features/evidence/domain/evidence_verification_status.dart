/// สถานะของการตรวจสอบหลักฐาน — ใช้ใน store และ UI
///
/// Sprint 9A: เลือก enum เรียบง่ายที่สุด (ตามข้อกำหนด)
///
/// ค่าที่เป็นไปได้:
///  - [idle]      ยังไม่ได้เลือก/ยังไม่ได้ตรวจ
///  - [verifying] กำลังตรวจสอบ (UI แสดง loading, ป้องกัน double submit)
///  - [passed]    ตรวจผ่าน
///  - [rejected]  ตรวจไม่ผ่าน (retry ได้)
///  - [error]     verifier โยน exception (retry ได้ ไม่ crash)
enum EvidenceVerificationStatus {
  idle,
  verifying,
  passed,
  rejected,
  error,
}
