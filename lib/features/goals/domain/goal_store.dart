import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'goal.dart';
import 'goal_id_generator.dart';

/// ที่เก็บรายการเป้าหมาย (Goal) และ "Active Goal" ของทั้งแอป
///
/// เป็น [ChangeNotifier] เพื่อให้ widget ที่ฟัง rebuild อัตโนมัติเมื่อข้อมูลเปลี่ยน
/// ทำให้ Home กับ Goals แสดงข้อมูลเดียวกันและอัปเดตพร้อมกัน
///
/// Sprint 3 เพิ่ม:
///  - **CRUD**: สร้าง/แก้/ลบ เป้าหมาย
///  - **Active Goal**: มีได้ทีละตัว — Home แสดง active, Start Study ใช้ active
///  - **Persistence**: บันทึก/กู้คืนจาก SharedPreferences (เก็บทั้ง list และ id ของ active)
///
/// Storage keys (SharedPreferences):
///  - `goals`        JSON string ของ `[Goal.toJson(), ...]`
///  - `active_goal`  id ของเป้าหมายที่ active (อาจเป็น id ที่ไม่มีใน list ก็ได้ → getter คืน null)
class GoalStore extends ChangeNotifier {
  GoalStore();

  final List<Goal> _goals = [];
  String? _activeGoalId;

  /// รายการเป้าหมายทั้งหมด (อ่านได้อย่างเดียวจากภายนอก)
  List<Goal> get goals => List.unmodifiable(_goals);

  /// เป้าหมายที่ active ในขณะนี้ (อาจเป็น null ถ้ายังไม่ได้ตั้ง หรือถูกลบไปแล้ว)
  Goal? get activeGoal {
    if (_activeGoalId == null) return null;
    return _goals.where((g) => g.id == _activeGoalId).firstOrNull;
  }

  /// id ของ active goal (เผื่อ UI หรือ logic อื่นต้องการ)
  String? get activeGoalId => _activeGoalId;

  /// มี active goal หรือไม่ (ใช้สำหรับปุ่ม Start Study: disable ถ้าไม่มี)
  bool get hasActiveGoal => activeGoal != null;

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  /// เพิ่มเป้าหมายใหม่ แล้วแจ้ง listener + บันทึก
  void add(Goal goal) {
    _goals.add(goal);
    _persist();
    notifyListeners();
  }

  /// สร้างเป้าหมายใหม่จากข้อมูลฟอร์ม (title + targetMinutes)
  /// คำนวณ id/createdAt ภายใน domain layer ก่อนเพิ่ม
  /// ถ้าเป็นเป้าหมายแรก → ตั้งเป็น active อัตโนมัติ (สะดวกผู้ใช้)
  void createGoal({required String title, required int targetMinutes}) {
    final goal = Goal(
      id: GoalIdGenerator.nextIdFor(_goals),
      title: title,
      targetMinutes: targetMinutes,
      createdAt: DateTime.now(),
    );
    final wasEmpty = _goals.isEmpty;
    _goals.add(goal);
    if (wasEmpty) {
      _activeGoalId = goal.id;
    }
    _persist();
    notifyListeners();
  }

  /// แก้ไขเป้าหมายที่มี id ตรงกัน — อัปเดต title/targetMinutes
  /// คืน true ถ้าหาเจอและอัปเดต, false ถ้าไม่มี id นั้น
  bool updateGoal({
    required String id,
    required String title,
    required int targetMinutes,
  }) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return false;
    _goals[index] = Goal(
      id: id,
      title: title,
      targetMinutes: targetMinutes,
      // คง createdAt เดิมไว้ (ไม่เปลี่ยนวันสร้างตอนแก้ไข)
      createdAt: _goals[index].createdAt,
    );
    _persist();
    notifyListeners();
    return true;
  }

  /// ลบเป้าหมาย — ถ้าตัวที่ลบเป็น active ให้ย้าย active ไปตัวอื่น
  /// (เลือกตัวแรกที่เหลือ หรือ null ถ้าไม่เหลือ)
  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    if (_activeGoalId == id) {
      _activeGoalId = _goals.isEmpty ? null : _goals.first.id;
    }
    _persist();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Active goal
  // ---------------------------------------------------------------------------

  /// ตั้งเป้าหมายที่ id ตรงกันเป็น active — ถ้า id ไม่มีใน list จะไม่ทำอะไร
  void setActiveGoal(String id) {
    if (_goals.indexWhere((g) => g.id == id) == -1) return;
    if (_activeGoalId == id) return; // เป็น active อยู่แล้ว → ไม่ต้องแจ้ง
    _activeGoalId = id;
    _persist();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Persistence (SharedPreferences)
  // ---------------------------------------------------------------------------

  /// คีย์ SharedPreferences — แยกเป็น constant เพื่อใช้ซ้ำ
  static const String goalsKey = 'goals';
  static const String activeKey = 'active_goal';

  /// กู้คืนข้อมูลจาก SharedPreferences — เรียกตอนเปิดแอป (ก่อน runApp)
  ///
  /// อ่าน list ของ Goal และ id ของ active กลับมาใน memory
  /// ถ้ายังไม่เคยบันทึก (เปิดครั้งแรก) จะเป็นค่าว่าง/empty ตามปกติ
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final goalsJson = prefs.getString(goalsKey);
    if (goalsJson != null) {
      final list = jsonDecode(goalsJson) as List;
      _goals
        ..clear()
        ..addAll(list.map((e) => Goal.fromJson(e as Map<String, Object?>)));
    }

    _activeGoalId = prefs.getString(activeKey);
    // กัน edge case: active id ที่เก็บไว้หาใน list ไม่ได้ → คืน null (ปลอดภัยกว่าค้างไว้)
    if (_activeGoalId != null &&
        _goals.indexWhere((g) => g.id == _activeGoalId) == -1) {
      _activeGoalId = null;
    }

    notifyListeners();
  }

  /// บันทึก state ปัจจุบันลง SharedPreferences (เรียกทุกครั้งที่เปลี่ยนข้อมูล)
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = jsonEncode(_goals.map((g) => g.toJson()).toList());
    await prefs.setString(goalsKey, goalsJson);
    if (_activeGoalId != null) {
      await prefs.setString(activeKey, _activeGoalId!);
    } else {
      await prefs.remove(activeKey);
    }
  }
}
