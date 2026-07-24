import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/goal.dart';
import '../../domain/goal_id_generator.dart';

/// Dialog สร้างเป้าหมายใหม่ของ StudySprout
///
/// ฟอร์มมีสอง field:
///  - Title          ชื่อเป้าหมาย (ข้อความ)
///  - Target Minutes เป้าหมายเวลาเรียน (ตัวเลขจำนวนเต็ม)
/// ปุ่ม: Cancel / Save
///
/// เมื่อ Save แล้วจะคืน [Goal] ใหม่กลับไป (หรือ null ถ้ายกเลิก)
/// ตัว dialog เป็น widget ล้วน ๆ — ส่วนสร้าง id/วันที่อยู่ใน domain layer
class GoalCreateDialog extends StatefulWidget {
  const GoalCreateDialog({super.key, required this.existingGoals});

  /// รายการเป้าหมายที่มีอยู่ — ส่งมาเพื่อคำนวณ id ใหม่ไม่ให้ซ้ำ
  final List<Goal> existingGoals;

  /// เปิด dialog สร้างเป้าหมาย คืน [Goal] ที่สร้าง หรือ null ถ้ายกเลิก
  static Future<Goal?> show(
    BuildContext context,
    List<Goal> existingGoals,
  ) {
    return showDialog<Goal>(
      context: context,
      builder: (context) => GoalCreateDialog(existingGoals: existingGoals),
    );
  }

  @override
  State<GoalCreateDialog> createState() => _GoalCreateDialogState();
}

class _GoalCreateDialogState extends State<GoalCreateDialog> {
  final _titleController = TextEditingController();
  final _minutesController = TextEditingController();
  String? _titleError;
  String? _minutesError;

  @override
  void dispose() {
    _titleController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  /// ตรวจสอบความถูกต้องของ input ก่อนสร้าง Goal
  /// คืน [Goal] ถ้าผ่าน, หรือ null ถ้า input ไม่สมบูรณ์ (พร้อมตั้งค่า error)
  Goal? _buildGoalIfValid() {
    final title = _titleController.text.trim();
    final minutes = int.tryParse(_minutesController.text.trim());

    String? titleError;
    String? minutesError;

    if (title.isEmpty) {
      titleError = 'Please enter a title';
    }
    if (minutes == null || minutes <= 0) {
      minutesError = 'Please enter a valid number';
    }

    // มี error → ตั้งค่าให้ field แสดงข้อความ แล้วคืน null
    if (titleError != null || minutesError != null) {
      setState(() {
        _titleError = titleError;
        _minutesError = minutesError;
      });
      return null;
    }

    return Goal(
      id: GoalIdGenerator.nextIdFor(widget.existingGoals),
      title: title,
      targetMinutes: minutes!,
      createdAt: DateTime.now(),
    );
  }

  void _save() {
    final goal = _buildGoalIfValid();
    if (goal != null) {
      Navigator.of(context).pop(goal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Field: Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: const OutlineInputBorder(),
                errorText: _titleError,
              ),
              textCapitalization: TextCapitalization.sentences,
              // พิมพ์ใหม่ → ล้าง error เดิม
              onChanged: (_) {
                if (_titleError != null) {
                  setState(() => _titleError = null);
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Field: Target Minutes
            TextField(
              controller: _minutesController,
              decoration: InputDecoration(
                labelText: 'Target Minutes',
                border: const OutlineInputBorder(),
                errorText: _minutesError,
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) {
                if (_minutesError != null) {
                  setState(() => _minutesError = null);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
