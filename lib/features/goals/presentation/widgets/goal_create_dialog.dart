import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/goal.dart';
import '../../domain/goal_id_generator.dart';

/// Dialog สร้าง/แก้ไขเป้าหมายของ StudySprout
///
/// ฟอร์มมีสอง field:
///  - Title          ชื่อเป้าหมาย (ข้อความ)
///  - Target Minutes เป้าหมายเวลาเรียน (ตัวเลขจำนวนเต็ม)
/// ปุ่ม: Cancel / Save
///
/// รองรับ 2 โหมด:
///  - **Create** (ไม่ส่ง [existingGoal]) → สร้าง [Goal] ใหม่ คืนกลับไป
///  - **Edit**   (ส่ง [existingGoal])     → คืน [GoalEditResult] ที่มี id เดิม + ค่าใหม่
///
/// ตัว dialog เป็น widget ล้วน ๆ — ส่วนสร้าง id/วันที่อยู่ใน domain layer
class GoalCreateDialog extends StatefulWidget {
  const GoalCreateDialog({
    super.key,
    required this.existingGoals,
    this.existingGoal,
  });

  /// รายการเป้าหมายที่มีอยู่ — ส่งมาเพื่อคำนวณ id ใหม่ไม่ให้ซ้ำ (โหมด Create)
  final List<Goal> existingGoals;

  /// เป้าหมายที่จะแก้ไข (โหมด Edit) — null = โหมด Create
  final Goal? existingGoal;

  /// เปิด dialog สร้างเป้าหมาย คืน [Goal] ที่สร้าง หรือ null ถ้ายกเลิก
  static Future<Goal?> showCreate(
    BuildContext context,
    List<Goal> existingGoals,
  ) {
    return showDialog<Goal>(
      context: context,
      builder: (context) => GoalCreateDialog(existingGoals: existingGoals),
    );
  }

  /// เปิด dialog แก้ไขเป้าหมาย คืน [GoalEditResult] หรือ null ถ้ายกเลิก
  static Future<GoalEditResult?> showEdit(
    BuildContext context,
    Goal goal,
  ) {
    return showDialog<GoalEditResult>(
      context: context,
      builder: (context) =>
          GoalCreateDialog(existingGoals: const [], existingGoal: goal),
    );
  }

  @override
  State<GoalCreateDialog> createState() => _GoalCreateDialogState();
}

/// ผลลัพธ์โหมด Edit — เก็บ id เดิม + ค่าใหม่ที่ผู้ใช้กรอก
class GoalEditResult {
  const GoalEditResult({required this.id, required this.title, required this.targetMinutes});

  final String id;
  final String title;
  final int targetMinutes;
}

class _GoalCreateDialogState extends State<GoalCreateDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _minutesController;
  String? _titleError;
  String? _minutesError;

  @override
  void initState() {
    super.initState();
    // โหมด Edit → ดึงค่าเดิมมาเติมในฟอร์ม; โหมด Create → ว่าง
    _titleController = TextEditingController(text: widget.existingGoal?.title ?? '');
    _minutesController = TextEditingController(
      text: widget.existingGoal == null
          ? ''
          : widget.existingGoal!.targetMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  /// ตรวจสอบความถูกต้องของ input — คืนค่าที่ผ่าน หรือตั้ง error ถ้าไม่ผ่าน
  /// คืน record `(title, minutes)` หรือ null
  ({String title, int minutes})? _validate() {
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

    if (titleError != null || minutesError != null) {
      setState(() {
        _titleError = titleError;
        _minutesError = minutesError;
      });
      return null;
    }

    return (title: title, minutes: minutes!);
  }

  void _save() {
    final result = _validate();
    if (result == null) return;

    if (widget.existingGoal != null) {
      // โหมด Edit → คืน GoalEditResult (id เดิม + ค่าใหม่)
      Navigator.of(context).pop(
        GoalEditResult(
          id: widget.existingGoal!.id,
          title: result.title,
          targetMinutes: result.minutes,
        ),
      );
    } else {
      // โหมด Create → คืน Goal ใหม่
      Navigator.of(context).pop(
        Goal(
          id: GoalIdGenerator.nextIdFor(widget.existingGoals),
          title: result.title,
          targetMinutes: result.minutes,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingGoal != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Goal' : 'Create Goal'),
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
        FilledButton(onPressed: _save, child: Text(isEdit ? 'Save' : 'Create')),
      ],
    );
  }
}
