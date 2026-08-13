import 'verification_result.dart';

/// Abstraction ของ "ผู้ตรวจสอบหลักฐาน" — **generic contract**
///
/// Sprint 9A: Presentation รู้จักแค่ interface นี้เท่านั้น ไม่รู้ว่า implementation จริง
/// ในอนาคต (Sprint 9B) คือ Gemini / Supabase / HTTP endpoint
///
/// Flow ที่ UI เห็น:
/// ```
/// goal title + image bytes
///   → EvidenceVerifier.verify()
///   → VerificationResult
/// ```
///
/// การใช้ `List<int>` สำหรับ image bytes เพื่อให้ทดสอบง่าย (test double ใส่ byte fixture
/// ได้โดยตรง) — Sprint 9B อาจ map เป็น Uint8List ภายใน implementation ได้
abstract interface class EvidenceVerifier {
  /// ตรวจสอบหลักฐานรูปภาพเทียบกับชื่อเป้าหมาย
  ///
  /// - [goalTitle]  ชื่อเป้าหมายที่ผู้ใช้กำลังเรียน (เป็น context ให้ verifier)
  /// - [imageBytes] bytes ของรูปหลักฐาน (test ใช้ byte fixture ได้)
  ///
  /// คืน [VerificationResult] — โยน exception ได้เมื่อเกิดข้อผิดพลาด (store จะจับเป็น
  /// status `error` ไม่ให้ crash)
  Future<VerificationResult> verify({
    required String goalTitle,
    required List<int> imageBytes,
  });
}
