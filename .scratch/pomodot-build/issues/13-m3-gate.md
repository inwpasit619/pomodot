# 13 — M3 · 🛑 ด่านปิด milestone

**Milestone:** M3 · branch `feature/m3-notifications` → merge เข้า `develop`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ A8, A9 และ M3 › Checklist ทดสอบด้วยมือ M3

**What to build:** M3 ปิดได้อย่างถูกต้อง: ผ่านเงื่อนไข "เสร็จ" ครบ, ผู้ใช้ได้รายงานภาษาไทยและทำ checklist M3 (ฟังเสียง, กด Allow, Do Not Disturb) แล้วบอก "ผ่าน" จากนั้นงานถูก merge เข้า `develop` พร้อมให้ M4 เริ่ม

**Blocked by:** 12 — Banner notification

**Status:** ready-for-agent (มีจุดหยุดรอผู้ใช้ 🛑)

- [ ] ผ่านเงื่อนไข "เสร็จ" ทั้ง 7 ข้อใน A8
- [ ] `docs/manual-test.md` มีครบทุกข้อของ Checklist ทดสอบด้วยมือ M3
- [ ] รายงานส่งงานภาษาไทย 3 ส่วนตาม A8 ข้อ 7
- [ ] 🛑 รอผู้ใช้ทำ checklist M3 แล้วบอก "ผ่าน"
- [ ] `git merge --no-ff` จาก `feature/m3-notifications` เข้า `develop` แล้ว push `develop`
