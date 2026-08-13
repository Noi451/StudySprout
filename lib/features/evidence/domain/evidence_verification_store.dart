import 'dart:async';

import 'package:flutter/foundation.dart';

import 'evidence_verifier.dart';
import 'evidence_verification_status.dart';
import 'verification_result.dart';

/// สถานะการตรวจสอบหลักฐานของทั้ง feature — **state เท่านั้น ไม่มี business logic ของ
/// Goal/Session/XP** (Sprint 9A ห้ามแตะ FinishSessionService)
///
/// เป็น [ChangeNotifier] ตาม pattern โปรเจกต์ (ไม่ใช้ Provider/Riverpod/Bloc)
/// widget ที่ฟังจะ rebuild อัตโนมัติเมื่อสถานะเปลี่ยน
///
/// State:
///  - [status]      idle/verifying/passed/rejected/error
///  - [imageBytes]  bytes ของรูปที่เลือก (null = ยังไม่มี)
///  - [result]      ผลลัพธ์ล่าสุด (null ถ้ายังไม่เคยตรวจ/ถูก reset)
///
/// Methods:
///  - [setEvidence]  ตั้งรูปหลักฐาน → status = idle (พร้อม verify)
///  - [clearEvidence] ล้างรูป + result → status = idle
///  - [verify]       เรียก verifier (ป้องกัน double submit ด้วย _isBusy guard)
///  - [reset]        กลับ idle พร้อม retry (เก็บ imageBytes ไว้เพื่อเลือกใหม่/verify ใหม่ได้)
///
/// ไม่ได้ทำเป็น InheritedNotifier ระดับแอปเพราะ Sprint 9A เป็น feature แยก/ทดลอง
/// ไม่ต้องส่งข้ามแท็บ — page สร้าง store เฉพาะตัวแล้วหุ้มได้ (เหตุผล: local presentation
/// state เพียงพอและ maintainable กว่า ตามข้อกำหนด PART 3)
class EvidenceVerificationStore extends ChangeNotifier {
  EvidenceVerificationStore({required this.verifier});

  final EvidenceVerifier verifier;

  EvidenceVerificationStatus _status = EvidenceVerificationStatus.idle;
  List<int>? _imageBytes;
  VerificationResult? _result;

  /// guard กัน double submit ขณะกำลัง verify
  bool _isBusy = false;

  /// สถานะปัจจุบัน
  EvidenceVerificationStatus get status => _status;

  /// bytes ของรูปหลักฐาน (null = ยังไม่ได้เลือก)
  List<int>? get imageBytes => _imageBytes;

  /// ผลลัพธ์ล่าสุด (null ถ้ายังไม่เคยตรวจหรือถูก reset)
  VerificationResult? get result => _result;

  /// มีรูปหลักฐานพร้อม verify หรือไม่ (UI ใช้ปิด/เปิดปุ่ม Verify)
  bool get hasEvidence => _imageBytes != null && _imageBytes!.isNotEmpty;

  /// กำลังตรวจอยู่หรือไม่ (UI ใช้แสดง loading + disabled)
  bool get isVerifying => _status == EvidenceVerificationStatus.verifying;

  /// ตั้งรูปหลักฐาน → กลับ idle พร้อม verify ใหม่ได้ (ล้าง result เดิม)
  void setEvidence(List<int> bytes) {
    _imageBytes = bytes;
    _result = null;
    _status = EvidenceVerificationStatus.idle;
    notifyListeners();
  }

  /// ล้างรูป + result → idle (เหมือนเริ่มใหม่)
  void clearEvidence() {
    _imageBytes = null;
    _result = null;
    _status = EvidenceVerificationStatus.idle;
    notifyListeners();
  }

  /// ตรวจสอบหลักฐานผ่าน verifier
  ///
  /// - ป้องกัน double submit (_isBusy guard) และต้องมี evidence
  /// - ตั้ง status = verifying ก่อน await
  /// - สำเร็จ → passed/rejected ตาม result.passed
  /// - verifier โยน exception → status = error (ไม่ crash ไม่ commit อะไร)
  Future<void> verify({required String goalTitle}) async {
    if (_isBusy) return; // กันกดซ้ำ
    final bytes = _imageBytes;
    if (bytes == null || bytes.isEmpty) return; // ไม่มี evidence ไม่ตรวจ

    _isBusy = true;
    _status = EvidenceVerificationStatus.verifying;
    notifyListeners();

    try {
      final res = await verifier.verify(goalTitle: goalTitle, imageBytes: bytes);
      _result = res;
      _status = res.passed
          ? EvidenceVerificationStatus.passed
          : EvidenceVerificationStatus.rejected;
    } catch (_) {
      // verifier โยน exception → error state (retry ได้ ไม่ crash ไม่ commit)
      _status = EvidenceVerificationStatus.error;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// reset กลับ idle (เก็บ imageBytes ไว้เพื่อเลือกใหม่/verify ใหม่ได้ — ใช้หลัง rejected/error)
  ///
  /// หากต้องการล้างรูปด้วย ใช้ [clearEvidence]
  void reset() {
    _result = null;
    _status = EvidenceVerificationStatus.idle;
    notifyListeners();
  }
}
