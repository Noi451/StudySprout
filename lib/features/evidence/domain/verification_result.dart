/// ผลลัพธ์การตรวจสอบหลักฐาน (Evidence Verification) — **generic contract**
///
/// Sprint 9A: เป็น immutable data class ล้วน ๆ สำหรับส่งจาก [EvidenceVerifier]
/// ไปยัง UI — **ไม่มี field เฉพาะ Gemini/Supabase/HTTP** (Sprint 9B ค่อยใส่)
///
/// ฟิลด์:
///  - [passed]     ผ่านการตรวจหรือไม่
///  - [confidence] ความมั่นใจของการตัดสินใจ 0.0–1.0 (validate ใน constructor)
///  - [reason]     ข้อความสั้นสำหรับ UI อธิบายผลลัพธ์
final class VerificationResult {
  /// สร้างผลลัพธ์ — [confidence] นอกช่วง 0.0–1.0 จะถูก clamp
  const VerificationResult({
    required this.passed,
    required double confidence,
    required this.reason,
  }) : confidence = confidence < 0
            ? 0.0
            : (confidence > 1 ? 1.0 : confidence);

  final bool passed;

  /// ความมั่นใจ 0.0–1.0 (รับประกันอยู่ในช่วงเสมอเพราะ clamp ใน constructor)
  final double confidence;

  /// ข้อความสั้น ๆ สำหรับแสดงใน UI (เช่น "This appears related to your study goal.")
  final String reason;

  /// ตัวอย่างผลลัพธ์ที่ผ่าน (ใช้ใน test/preview เท่านั้น — ไม่ใช่ production data)
  static const VerificationResult accepted = VerificationResult(
    passed: true,
    confidence: 0.9,
    reason: 'This appears related to your study goal.',
  );

  /// ตัวอย่างผลลัพธ์ที่ไม่ผ่าน
  static const VerificationResult rejected = VerificationResult(
    passed: false,
    confidence: 0.2,
    reason: 'This doesn’t appear to match your study goal.',
  );
}
