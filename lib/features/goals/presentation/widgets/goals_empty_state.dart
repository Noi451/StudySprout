import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_press_button.dart';
import '../../../../core/widgets/empty_state_panel.dart';

/// Empty State ของ Goals Page (Midnight Greenhouse) — ใช้ EmptyStatePanel กลาง
class GoalsEmptyState extends StatelessWidget {
  const GoalsEmptyState({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: EmptyStatePanel(
          icon: Icons.flag_outlined,
          title: 'No Goals Yet',
          caption: 'Create your first goal to start your study journey.',
          action: AppPressButton(
            label: 'Create Goal',
            onPressed: onCreate,
            isExpanded: false,
            icon: Icons.add,
          ),
        ),
      ),
    );
  }
}
