import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../goals/domain/goal_store_provider.dart';
import 'widgets/active_session_card.dart';
import 'widgets/goal_card.dart';
import 'widgets/start_study_button.dart';
import 'widgets/streak_card.dart';
import 'widgets/tree_section.dart';
import 'widgets/welcome_section.dart';
import 'widgets/xp_card.dart';

/// หน้าหลัก (Home) — แท็บที่ 1
///
/// Sprint 3: แสดง Active Goal (ไม่ใช่ latestGoal) — ถ้าเปลี่ยน active ที่ Goals Page
/// หน้านี้อัปเดตอัตโนมัติผ่าน [GoalStoreProvider]/InheritedNotifier
/// ถ้ายังไม่มีเป้าหมาย → Goal Card แสดง empty state
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ดึง active goal จาก store กลาง — rebuild อัตโนมัติเมื่อ store เปลี่ยน
    // (Sprint 3: ใช้ active goal แทน latestGoal)
    final store = GoalStoreProvider.of(context);
    final activeGoal = store.activeGoal;

    return Scaffold(
      // ไม่มี AppBar เพื่อให้หน้าดูสะอาด มีพื้นที่ว่างเยอะตามสไตล์ calm/minimal
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          // Sprint 6: ใช้ LayoutBuilder + SingleChildScrollView + IntrinsicHeight
          // (canonical "fill space, scroll if needed" pattern) — เมื่อจอสูงพอ ทุกอย่าง
          // พอดีและ TreeSection ยืดเต็มที่เหลือ; เมื่อจอเล็กเกินไปจะเลื่อนได้แทนการล้น
          // ทะลุ (กัน RenderFlex overflow โดยไม่ใช้ ClipRect ซ่อน)
          // IntrinsicHeight ทำให้ Column ได้ bounded height → Expanded ใช้ได้
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. ข้อความต้อนรับ
                        const WelcomeSection(),
                        const SizedBox(height: AppSpacing.sm),

                        // 2. ต้นไม้กึ่งกลาง — กินพื้นที่ว่างที่เหลือ (ยืดหยุ่นตามจอ ไม่ล้น)
                        const Expanded(child: TreeSection()),

                      // 3. XP + Streak วางคู่กัน 2 คอลัมน์
                      // Sprint 6: ลบ IntrinsicHeight + stretch (เคยบังคับให้การ์ดสูงเท่ากัน →
                      // กินพื้นที่คงที่มากจน Column overflow 16px) ใช้ start แทน การ์ดสูงตามเนื้อหา
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: XpCard()),
                          SizedBox(width: AppSpacing.md),
                          Expanded(child: StreakCard()),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // 4. เป้าหมายของวันนี้ — แสดง active goal หรือ empty state
                      GoalCard(goal: activeGoal),

                      const SizedBox(height: AppSpacing.xxl),

                      // 5. ปุ่มเริ่มเรียน — disabled ถ้ายังไม่มี active goal
                      StartStudyButton(goal: activeGoal),

                      const SizedBox(height: AppSpacing.xxl),

                      // 6. สถานะ session ที่กำลังเรียนอยู่ (ถ้ามี) — แตะเพื่อกลับเข้า Timer ต่อ
                      const ActiveSessionCard(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
