import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state_panel.dart';
import '../../../../core/widgets/app_press_button.dart';
import '../domain/goal_store_provider.dart';
import 'widgets/goal_card.dart';
import 'widgets/goal_create_dialog.dart';

/// หน้าเป้าหมาย (Goals) — แท็บที่ 2
///
/// Sprint 3: ระบบ CRUD ใช้งานจริง
/// Sprint 8: ใช้ Product Identity ใหม่ (Midnight Greenhouse) + responsive frame
class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  Future<void> _openCreateGoalDialog(BuildContext context) async {
    final store = GoalStoreProvider.of(context);
    final goal = await GoalCreateDialog.showCreate(context, store.goals);
    if (goal != null) store.add(goal);
  }

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

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final store = GoalStoreProvider.of(context);
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
    if (confirmed == true) store.deleteGoal(id);
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
          // Sprint 8.1: empty state อยู่ช่วงบน/กลางที่สมเหตุผล ไม่ลอยกลางพื้นที่ว่างมหาศาล
          // ใช้ SingleChildScrollView + top spacing จาก spacing tokens (xxxl×3 = 96)
          ? SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.xxxl * 3,
                ),
                child: Center(
                  child: EmptyStatePanel(
                    icon: Icons.flag_outlined,
                    title: 'No Goals Yet',
                    caption: 'Create your first goal to start your study journey.',
                    action: AppPressButton(
                      label: 'Create Goal',
                      onPressed: () => _openCreateGoalDialog(context),
                      icon: Icons.add,
                    ),
                  ),
                ),
              ),
            )
          : SafeArea(
              child: ResponsivePageFrame(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.xl,
                    bottom: AppSpacing.xxxl,
                  ),
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
              ),
            ),
      floatingActionButton: isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => _openCreateGoalDialog(context),
              child: const Icon(Icons.add),
            ),
    );
  }
}
