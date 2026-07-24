/// ชุดค่าระยะห่าง (spacing) ของ Design System StudySprout
///
/// ใช้สเกล 4px เป็นหน่วยฐาน (4pt grid) — ค่าทั้งหมดเป็นพหุคูณของ 4
/// เพื่อให้ระยะห่างทั้งแอป "ตกลงบนกริดเดียวกัน" ดูเป็นระบบ
///
/// ตัวอย่างการใช้งาน:
/// ```
/// Padding(padding: EdgeInsets.all(AppSpacing.lg))   // แทน EdgeInsets.all(16)
/// SizedBox(height: AppSpacing.sm)                    // แทน SizedBox(height: 8)
/// ```
class AppSpacing {
  AppSpacing._(); // ป้องกันการสร้าง instance

  /// 4 px — ระยะห่างขั้นต่ำ ใช้กับช่องว่างเล็ก ๆ ใน widget ย่อย
  static const double xs = 4;

  /// 8 px — ระยะห่างระหว่างองค์ประกอบที่ใกล้กัน
  static const double sm = 8;

  /// 12 px — ระยะห่างกลางระหว่าง widget คนละกลุ่ม
  static const double md = 12;

  /// 16 px — padding ภายในการ์ด/ส่วนต่าง ๆ
  static const double lg = 16;

  /// 20 px — padding ขอบหน้าจอ (screen edge)
  static const double xl = 20;

  /// 24 px — ระยะห่างใหญ่ระหว่างส่วนหลักของหน้า
  static const double xxl = 24;

  /// 32 px — ระยะห่างใหญ่พิเศษ (หัว/ท้ายหน้า)
  static const double xxxl = 32;
}
