import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../domain/goal_store.dart';
import '../domain/goal_store_provider.dart';
import 'widgets/goal_card.dart';
import 'widgets/goal_create_dialog.dart';
import 'widgets/goals_empty_state.dart';

/// หน้าเป้าหมาย (Goals) — แท็บที่ 2
///
/// Milestone 4: Goal Foundation — ผู้ใช้สามารถสร้าง Goal ได้ (เก็บใน memory เท่านั้น)
///
/// ดึงรายการเป้าหมายจาก [GoalStore] กลาง (ส่งผ่าน [GoalStoreProvider])
/// ดังนั้นเป้าหมายที่สร้างที่นี่จะแสดงที่หน้า Home ด้วย — และกลับกัน
/// หน้านี้เป็น StatelessWidget เพียงพอ เพราะ state อยู่ใน store แล้ว
class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  /// เปิด dialog สร้างเป้าหมาย แล้วเพิ่มเข้า [GoalStore]
  Future<void> _openCreateGoalDialog(BuildContext context) async {
    final store = GoalStoreProvider.of(context);
    final goal = await GoalCreateDialog.show(context, store.goals);
    if (goal != null) {
      store.add(goal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = GoalStoreProvider.of(context);
    final goals = store.goals;
    final isEmpty = goals.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: isEmpty
          ? GoalsEmptyState(
              onCreate: () => _openCreateGoalDialog(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: GoalCard(goal: goals[index]),
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
