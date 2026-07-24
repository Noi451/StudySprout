import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// พื้นที่ต้นไม้กึ่งกลางหน้า Home
///
/// ประกอบด้วยวงกลมพื้นหลัง (halo) สีเขียวอ่อนโปร่งแสง กับไอคอนต้นไม้ตรงกลาง
/// เป็น placeholder เตรียมพื้นที่ไว้สำหรับ "ต้นไม้จริง" ใน milestone ถัดไป
///
/// ไม่กำหนดความสูงตายตัว — ให้ผู้ใช้หุ้มด้วย [Expanded] เพื่อยืดหยุ่นตามจอ
class TreeSection extends StatelessWidget {
  const TreeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // วงกลมพื้นหลัง (halo) — เขียวอ่อนโปร่งแสง ขนาดคงที่
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.treeHalo,
              shape: BoxShape.circle,
            ),
          ),
          // Placeholder ต้นไม้ — ไอคอนเขียวเด่นอยู่ตรงกลางวงกลม
          // ส่วนนี้จะถูกแทนด้วยรูปต้นไม้จริงใน milestone ถัดไป
          Icon(
            Icons.park,
            size: 120,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
