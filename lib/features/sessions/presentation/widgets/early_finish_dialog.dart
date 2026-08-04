import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';

/// Dialog ยืนยันการจบ session ก่อถึงเป้า (Early Finish confirmation) — **UI เท่านั้น**
///
/// Sprint 6: ผู้ใช้กด Finish ขณะยังเรียนไม่ครบเป้าหมาย → ต้องถามยืนยันก่อน commit
/// (ตามข้อกำหนด "Early Finish confirmation")
///
/// คำถามกำหนดไว้ตายตัว:
///  - Title : "Are you sure?"
///  - Body  : "You haven't reached your study goal yet."
///  - Actions: "Continue Studying" / "Finish Anyway"
///
/// คืนค่าจาก [show] เป็น `bool`:
///  - `true`  → เลือก **Finish Anyway** (caller ไปเรียก `FinishSessionService.commit()`)
///  - `false` → เลือก **Continue Studying** หรือปิด dialog ด้วยวิธีอื่น
///    (caller ปิด dialog แล้วปล่อยให้ timer ทำงานต่อ — ห้าม pause อัตโนมัติ)
///
/// เป็น widget ล้วน ๆ — ไม่จับต้อง store/service ใด ๆ ทั้งสิ้น (presentation only)
class EarlyFinishDialog extends StatelessWidget {
  const EarlyFinishDialog({super.key});

  /// เปิด dialog ยืนยัน — คืน `true` ถ้าเลือก Finish Anyway, `false` ถ้าเลือก
  /// Continue Studying หรือปิด dialog ไปเลย (barrier/Escape นับเป็น Continue)
  static Future<bool> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      // กดนอก/Escape นับเป็น "Continue Studying" → คืน false (timer ทำงานต่อ)
      barrierDismissible: true,
      builder: (context) => const EarlyFinishDialog(),
    ).then((value) => value ?? false); // null (กดนอก) → false
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Are you sure?'),
      content: const Text("You haven't reached your study goal yet."),
      actions: [
        // Continue Studying → ปิด dialog, timer ทำงานต่อ (caller ไม่ทำอะไรเพิ่ม)
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Continue Studying'),
        ),
        // Finish Anyway → คืน true ให้ caller ไป commit (flow Sprint 5.1)
        FilledButton(
          style: FilledButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Finish Anyway'),
        ),
      ],
    );
  }
}
