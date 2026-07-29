import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../progress/domain/progress_store_provider.dart';
import '../../../progress/domain/tree_stage.dart';

/// พื้นที่ต้นไม้กึ่งกลางหน้า Home
///
/// Sprint 5: แสดงระยะต้นไม้ (TreeStage) จริงจาก [ProgressStore] — ต้นไม้โตจาก Level
/// (ไม่ใช่จากเวลา) ผ่าน [TreeStageCalculator] (logic อยู่ใน domain layer)
///
/// Sprint 6: เปลี่ยนอิโมจิขนาดใหญ่ (fontSize 96) → **Material Icon** เพื่อให้แสดงผลได้
/// ทุกอุปกรณ์ (ก่อนหน้านี้แอปไม่ได้ bundle ฟอนต์ emoji จึงเกิด glyph fallback เป็น
/// ตัวอักษร "ee" บนบางอุปกรณ์) — ใช้ icon ของ Material ที่ bundle อยู่แล้วแก้ที่ต้นเหตุ
///
/// ไม่กำหนดความสูงตายตัว — ให้ผู้ใช้หุ้มด้วย [Expanded] เพื่อยืดหยุ่นตามจอ
/// rebuild อัตโนมัติผ่าน [ProgressStoreProvider]/InheritedNotifier เมื่อ level เปลี่ยน
class TreeSection extends StatelessWidget {
  const TreeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stage = ProgressStoreProvider.of(context).treeStage;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
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
              // ไอคอนต้นไม้ตามระยะ — Material Icon (render ได้ทุกอุปกรณ์ กัน glyph fallback)
              Icon(
                _iconFor(stage),
                size: 120,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ป้ายชื่อระยะต้นไม้ (ข้อความธรรมดา → render ได้ทุกที่)
          Text(
            stage.label,
            style: AppTextStyles.label(context),
          ),
        ],
      ),
    );
  }

  /// เลือก Material Icon ตามระยะต้นไม้ — เป็น mapping ของ UI (ไม่ใช่ business logic)
  static IconData _iconFor(TreeStage stage) {
    switch (stage) {
      case TreeStage.seed:
        return Icons.grain; // เมล็ดพันธุ์
      case TreeStage.sprout:
        return Icons.spa; // ต้นอ่อนโผล่
      case TreeStage.smallPlant:
        return Icons.park_outlined; // ต้นเล็ก
      case TreeStage.youngTree:
        return Icons.park; // ต้นหนุ่ม
      case TreeStage.tree:
        return Icons.forest; // ต้นไม้ใหญ่
      case TreeStage.bigTree:
        return Icons.forest; // ต้นไม้ใหญ่มาก (ใช้ forest เดียวกัน ต่างที่ label)
    }
  }
}
