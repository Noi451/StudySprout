/// สถานะของ "Session การเรียน" หนึ่งรอบ
///
/// ใช้ใน [StudySession] และ [SessionStore] เพื่อบอกว่าตอนนี้ session
/// อยู่ในช่วงไหนของวงจรการเรียน
///
/// ค่าที่เป็นไปได้:
///  - [running]   กำลังเรียนอยู่ (timer กำลังนับขึ้น)
///  - [paused]    กดพักชั่วคราว (timer หยุดนับ แต่ยังไม่จบ)
///  - [completed] กด Finish จบรอบเรียนแล้ว (เก็บลง history)
enum SessionStatus { running, paused, completed }
