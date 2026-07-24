import 'package:flutter/foundation.dart';

import 'goal.dart';
import 'goal_id_generator.dart';

/// ที่เก็บรายการเป้าหมาย (Goal) แบบ local in-memory — สำหรับทั้งแอป
///
/// เป็น [ChangeNotifier] เพื่อให้ widget ที่ฟัง (ListenableBuilder) รู้ว่ารายการเปลี่ยน
/// แล้ว rebuild อัตโนมัติ — ทำให้ Home กับ Goals แสดงข้อมูลเดียวกันและอัปเดตพร้อมกัน
///
/// ยังไม่มีการบันทึกลง Database/SharedPreferences — เก็บใน memory เท่านั้น
///
/// ตัวนี้เป็น "state" ล้วน ๆ ไม่ใช่ business logic ที่ต้องห้าม
/// (เพราะเป็นการเก็บข้อมูลตามข้อกำหนด Milestone 4: Local in-memory List)
class GoalStore extends ChangeNotifier {
  final List<Goal> _goals = [];

  /// รายการเป้าหมายทั้งหมด (อ่านได้อย่างเดียวจากภายนอก)
  List<Goal> get goals => List.unmodifiable(_goals);

  /// เป้าหมายล่าสุด — ใช้ในหน้า Home (ถ้ามี)
  Goal? get latestGoal =>
      _goals.isEmpty ? null : _goals[_goals.length - 1];

  /// เพิ่มเป้าหมายใหม่ แล้วแจ้ง listener ให้ rebuild
  void add(Goal goal) {
    _goals.add(goal);
    notifyListeners();
  }

  /// สร้างเป้าหมายใหม่จากข้อมูลฟอร์ม (title + targetMinutes)
  /// คำนวณ id/createdAt ภายใน domain layer ก่อนเพิ่ม
  void createGoal({required String title, required int targetMinutes}) {
    final goal = Goal(
      id: GoalIdGenerator.nextIdFor(_goals),
      title: title,
      targetMinutes: targetMinutes,
      createdAt: DateTime.now(),
    );
    add(goal);
  }
}
