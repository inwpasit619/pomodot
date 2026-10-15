# 10 — M2 · 🛑 ด่านปิด milestone

**Milestone:** M2 · branch `feature/m2-timer` → merge เข้า `develop`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ A8, A9 และ M2 › Checklist ทดสอบด้วยมือ M2

**What to build:** M2 ปิดได้อย่างถูกต้อง: ผ่านเงื่อนไข "เสร็จ" ครบ, ผู้ใช้ได้รายงานภาษาไทยและทำ checklist M2 แล้วบอก "ผ่าน" จากนั้นงานถูก merge เข้า `develop` พร้อมให้ M3 เริ่ม

**Blocked by:** 09 — จำสถานะข้ามการ Quit

**Status:** ready-for-agent (มีจุดหยุดรอผู้ใช้ 🛑)

- [ ] ผ่านเงื่อนไข "เสร็จ" ทั้ง 7 ข้อใน A8
- [ ] `docs/manual-test.md` มีครบทุกข้อของ Checklist ทดสอบด้วยมือ M2 และ agent ทำเองแล้วในข้อที่ทำได้
- [ ] รายงานส่งงานภาษาไทย 3 ส่วนตาม A8 ข้อ 7 (รวมถึงเรื่องเปิดแอพซ้ำ ถ้าทำต่างจาก `applicationShouldHandleReopen`)
- [ ] 🛑 รอผู้ใช้ทำ checklist M2 แล้วบอก "ผ่าน"
- [ ] `git merge --no-ff` จาก `feature/m2-timer` เข้า `develop` แล้ว push `develop`
