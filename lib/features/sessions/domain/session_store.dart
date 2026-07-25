import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../goals/domain/goal.dart';
import 'session_id_generator.dart';
import 'session_status.dart';
import 'study_session.dart';

/// ที่เก็บสถานะ "Session การเรียน" แบบ local in-memory — สำหรับทั้งแอป
///
/// เป็น [ChangeNotifier] เพื่อให้ widget ที่ฟัง rebuild อัตโนมัติเมื่อสถานะเปลี่ยน
/// (เช่น เวลาที่เพิ่มขึ้นทุกวินาที, กด Pause/Resume/Finish)
///
/// โครงสร้างภายใน:
///  - [_current]  session ที่กำลัง active (running/paused) — null เมื่อไม่มี session ค้างอยู่
///  - [_history]  รายการ session ที่ completed แล้ว
///  - [_ticker]   [Timer.periodic] ที่ tick ทุก 1 วินาทีขณะ running
///
/// ตัวนี้เป็น "state" ล้วน ๆ — เป็นการจัดการสถานะตามข้อกำหนด Sprint 2
/// ยังไม่มีการบันทึกถาวร (ไม่ใช้ SharedPreferences ตามกฎโปรเจกต์)
class SessionStore extends ChangeNotifier {
  StudySession? _current;
  final List<StudySession> _history = [];
  Timer? _ticker;

  /// session ที่กำลัง active (running/paused) — null ถ้าไม่มี
  StudySession? get current => _current;

  /// รายการ session ที่จบแล้ว (อ่านได้อย่างเดียวจากภายนอก)
  List<StudySession> get history => List.unmodifiable(_history);

  /// มี session ค้างอยู่หรือไม่ (running หรือ paused)
  bool get isActive =>
      _current != null && _current!.status != SessionStatus.completed;

  /// สถานะของ session ปัจจุบัน — null ถ้าไม่มี session active
  SessionStatus? get status => _current?.status;

  /// เวลาที่เรียนสะสม (วินาที) ของ session ปัจจุบัน — 0 ถ้าไม่มี session
  int get elapsedSeconds => _current?.elapsedSeconds ?? 0;

  /// ความคืบหน้าไปยังเป้าหมาย (0.0–1.0) ของ session ปัจจุบัน
  ///
  /// คำนวณจาก `elapsedSeconds / (targetMinutes * 60)` แล้ว clamp ไม่ให้เกิน 1.0
  /// ถ้าไม่มี session หรือ targetMinutes เป็น 0 → คืน 0.0
  double get progress {
    if (_current == null || _current!.targetMinutes <= 0) return 0.0;
    final targetSeconds = _current!.targetMinutes * 60;
    final ratio = _current!.elapsedSeconds / targetSeconds;
    return ratio.clamp(0.0, 1.0);
  }

  /// เริ่ม session การเรียนใหม่จาก [goal]
  ///
  /// สร้าง [StudySession] สถานะ [SessionStatus.running], `elapsedSeconds = 0`,
  /// snapshot ชื่อ/เป้าหมายจาก goal แล้วเริ่ม ticker นับขึ้นทุกวินาที
  void startSession(Goal goal) {
    // ถ้ามี session ค้างอยู่อยู่แล้ว ไม่เริ่มทับ (ปล่อยให้เปิดหน้า timer เดิมต่อ)
    if (isActive) return;

    _ticker?.cancel();
    _current = StudySession(
      id: SessionIdGenerator.nextId(_history.length),
      goalId: goal.id,
      goalTitle: goal.title,
      targetMinutes: goal.targetMinutes,
      startedAt: DateTime.now(),
      elapsedSeconds: 0,
      status: SessionStatus.running,
    );
    _startTicker();
    notifyListeners();
  }

  /// พัก session ชั่วคราว — หยุด ticker เปลี่ยนสถานะเป็น [SessionStatus.paused]
  void pause() {
    if (_current == null || _current!.status != SessionStatus.running) return;
    _ticker?.cancel();
    _ticker = null;
    _current = _current!.copyWith(status: SessionStatus.paused);
    notifyListeners();
  }

  /// ทำต่อหลังพัก — เริ่ม ticker ใหม่ เปลี่ยนสถานะเป็น [SessionStatus.running]
  void resume() {
    if (_current == null || _current!.status != SessionStatus.paused) return;
    _current = _current!.copyWith(status: SessionStatus.running);
    _startTicker();
    notifyListeners();
  }

  /// จบ session ปัจจุบัน — เปลี่ยนสถานะเป็น [SessionStatus.completed],
  /// ยกเลิก ticker, ย้าย session ลง [_history] แล้วล้าง [_current]
  void finish() {
    if (_current == null) return;
    _ticker?.cancel();
    _ticker = null;
    final completed = _current!.copyWith(status: SessionStatus.completed);
    _history.add(completed);
    _current = null;
    notifyListeners();
  }

  /// เริ่ม ticker ที่ tick ทุก 1 วินาที — เรียกเฉพาะเมื่อ status == running
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// ถูกเรียกทุก tick — เพิ่ม elapsedSeconds ทีละ 1 แล้วแจ้ง listener rebuild
  ///
  /// เปิดเผยเป็น `@visibleForTesting` เพื่อให้ unit test เรียกจำลอง tick ได้
  /// (ทดสอบการเพิ่มเวลาและ clamp ของ progress โดยไม่ต้องรอ Timer จริง)
  @visibleForTesting
  void tick() {
    if (_current == null || _current!.status != SessionStatus.running) return;
    _current = _current!.copyWith(elapsedSeconds: _current!.elapsedSeconds + 1);
    notifyListeners();
  }

  void _tick() => tick();

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    super.dispose();
  }
}
