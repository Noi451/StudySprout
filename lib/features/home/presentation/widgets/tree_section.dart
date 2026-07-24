import 'package:flutter/material.dart';

/// พื้นที่ต้นไม้กึ่งกลางหน้า Home
///
/// ใช้ [Icon] รูปต้นไม้เป็น placeholder อยู่ตรงกลาง
/// ยังไม่ใช้รูปจริง ตามข้อกำหนดของ milestone นี้
///
/// ไม่กำหนดความสูงตายตัว — ให้ widget ย่อย/ผู้ใช้เป็นตัวกำหนดขนาด
/// (เช่น หุ้มด้วย [Expanded] ในหน้าหลัก เพื่อให้ต้นไม้กินพื้นที่ว่างที่เหลือ
/// และยืดหยุ่นตามขนาดจอ ไม่ล้นหน้าจอ)
class TreeSection extends StatelessWidget {
  const TreeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Icon(
        Icons.park,
        size: 120,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
