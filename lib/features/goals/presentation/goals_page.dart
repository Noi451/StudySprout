import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../domain/goal_store_provider.dart';
import 'widgets/goal_card.dart';
import 'widgets/goal_create_dialog.dart';
import 'widgets/goals_empty_state.dart';

/// หน้าเป้าหมาย (Goals) — แท็บที่ 2
///
/// Sprint 3: เป็นระบบ CRUD ใช้งานจริง
///  - สร้างเป้าหมาย (FAB / empty state button)
///  - แก้ไขเป้าหมาย (เมนู Edit ในการ์ด)
///  - ลบเป้าหมาย (เมนู Delete ในการ์ด + dialog ยืนยัน)
///  - ตั้ง Active Goal (เมนู Set Active ในการ์ด)
///
/// ดึงข้อมูลจาก [GoalStore] กลาง (ส่งผ่าน [GoalStoreProvider]) —
/// ทุกการเปลี่ยนแปลงจะอัปเดตหน้า Home ด้วยผ่าน InheritedNotifier
class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  /// เปิด dialog สร้างเป้าหมาย แล้วเพิ่มเข้า [GoalStore]
  Future<void> _openCreateGoalDialog(BuildContext context) async {
    final store = GoalStoreProvider.of(context);
    final goal = await GoalCreateDialog.showCreate(context, store.goals);
    if (goal != null) {
      store.add(goal);
    }
  }

  /// เปิด dialog แก้ไขเป้าหมาย แล้วอัปเดตใน [GoalStore]
  Future<void> _openEditGoalDialog(BuildContext context, String id) async {
    final store = GoalStoreProvider.of(context);
    final goal = store.goals.firstWhere((g) => g.id == id);
    final result = await GoalCreateDialog.showEdit(context, goal);
    if (result != null && context.mounted) {
      store.updateGoal(
        id: result.id,
        title: result.title,
        targetMinutes: result.targetMinutes,
      );
    }
  }

  /// ยืนยันลบเป้าหมาย แล้วลบจาก [GoalStore]
  Future<void> _confirmDelete(BuildContext context, String id) async {
    final store = GoalStoreProvider.of(context); // ดึง store ก่อน await
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      store.deleteGoal(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = GoalStoreProvider.of(context);
    final goals = store.goals;
    final activeId = store.activeGoalId;
    final isEmpty = goals.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: isEmpty
          ? GoalsEmptyState(onCreate: () => _openCreateGoalDialog(context))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: GoalCard(
                    goal: goal,
                    isActive: goal.id == activeId,
                    onSetActive: () => store.setActiveGoal(goal.id),
                    onEdit: () => _openEditGoalDialog(context, goal.id),
                    onDelete: () => _confirmDelete(context, goal.id),
                  ),
                );
              },
            ),
      // ปุ่มลอยสร้างเป้าหมาย — แสดงเฉพาะเมื่อมีเป้าหมายแล้ว
      // (empty state มีปุ่ม Create Goal ของตัวเองอยู่แล้ว)
      floatingActionButton: isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => _openCreateGoalDialog(context),
              child: const Icon(Icons.add),
            ),
    );
  }
}
