import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'widgets/goal_card.dart';
import 'widgets/start_study_button.dart';
import 'widgets/streak_card.dart';
import 'widgets/tree_section.dart';
import 'widgets/welcome_section.dart';
import 'widgets/xp_card.dart';

/// หน้าหลัก (Home) — แท็บที่ 1
///
/// Milestone 3: UI Polish & Design System — ปรับให้แอปมี Identity
/// ยังไม่มี business logic ใด ๆ ทุกค่าระยะ/รัศมีดึงจาก Design System ใน `core/theme/`
///
/// โครงหน้าประกอบด้วย 6 ส่วน แยกเป็น widget ย่อยใน `widgets/`:
///  1. [WelcomeSection]  — ข้อความต้อนรับ
///  2. [TreeSection]      — ต้นไม้กึ่งกลาง (วงกลม halo + placeholder)
///  3. [XpCard] + [StreakCard] — การ์ดสถิติ วางคู่กัน 2 คอลัมน์
///  4. [GoalCard]         — เป้าหมายของวันนี้ (empty state)
///  5. [StartStudyButton] — ปุ่มเริ่มเรียนด้านล่าง
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
              //    หุ้มด้วย IntrinsicHeight ให้ทั้งสองการ์ดสูงเท่ากัน
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

              // 4. เป้าหมายของวันนี้
              const GoalCard(),

              const SizedBox(height: AppSpacing.xxl),

              // 5. ปุ่มเริ่มเรียน
              const StartStudyButton(),
            ],
          ),
        ),
      ),
    );
  }
}
