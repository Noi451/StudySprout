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
/// Milestone 4: ถ้ามีเป้าหมาย → Goal Card แสดงเป้าหมายล่าสุดแทน "No Goal Yet"
///
/// ดึงเป้าหมายล่าสุดจาก [GoalStore] กลาง (ส่งผ่าน [GoalStoreProvider])
/// เมื่อผู้ใช้สร้างเป้าหมายที่ Goals Page หน้านี้จะอัปเดตอัตโนมัติ
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ดึงเป้าหมายล่าสุดจาก store กลาง — rebuild อัตโนมัติเมื่อ store เปลี่ยน
    final store = GoalStoreProvider.of(context);
    final latestGoal = store.latestGoal;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ข้อความต้อนรับ
              const WelcomeSection(),
              const SizedBox(height: AppSpacing.sm),

              // 2. ต้นไม้กึ่งกลาง — กินพื้นที่ว่างที่เหลือ (ยืดหยุ่นตามจอ ไม่ล้น)
              const Expanded(child: TreeSection()),

              // 3. XP + Streak วางคู่กัน 2 คอลัมน์
              const IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: XpCard()),
                    SizedBox(width: AppSpacing.md),
                    Expanded(child: StreakCard()),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 4. เป้าหมายของวันนี้ — แสดงเป้าหมายล่าสุด หรือ empty state
              GoalCard(goal: latestGoal),

              const SizedBox(height: AppSpacing.xxl),

              // 5. ปุ่มเริ่มเรียน — disabled ถ้ายังไม่มี Goal
              StartStudyButton(goal: latestGoal),

              const SizedBox(height: AppSpacing.xxl),

              // 6. สถานะ session ที่กำลังเรียนอยู่ (ถ้ามี) — แตะเพื่อกลับเข้า Timer ต่อ
              const ActiveSessionCard(),
            ],
          ),
        ),
      ),
    );
  }
}
