# 03 — M1 · 🛑 ด่านปิด milestone + push ครั้งแรก

**Milestone:** M1 · branch `feature/m1-floating-window` → merge เข้า `develop`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ A8, A9

**What to build:** M1 ปิดได้อย่างถูกต้อง: ผ่านเงื่อนไข "เสร็จ" ครบ, โค้ดมี backup อยู่บน GitHub, ผู้ใช้ได้รายงานภาษาไทยและทดสอบด้วยมือแล้วบอก "ผ่าน" จากนั้นงานถูก merge เข้า `develop` พร้อมให้ M2 เริ่ม

**Blocked by:** 02 — แคปซูลลอยอยู่บนสุด

**Status:** ready-for-agent (มีจุดหยุดรอผู้ใช้ 🛑 2 จุด)

- [ ] ผ่านเงื่อนไข "เสร็จ" ทั้ง 7 ข้อใน A8
- [ ] 🛑 **หยุดก่อน push ครั้งแรก:** ให้ผู้ใช้รัน `! gh auth login` แล้วเลือกบัญชี `inwpasit619` จากนั้นตรวจว่า `gh repo view inwpasit619/pomodot --json viewerPermission` ได้ `ADMIN` หรือ `WRITE` **ห้ามหาทางอ้อมเอง**
- [ ] remote `origin` = `https://github.com/inwpasit619/pomodot` แล้ว push `main`, `develop`, `feature/m1-floating-window` (รวม `.scratch/` และ `CLAUDE.md`) **ห้าม push** `research/*` และ `prototype/*`
- [ ] รายงานส่งงานภาษาไทย 3 ส่วนตาม A8 ข้อ 7
- [ ] 🛑 รอผู้ใช้ทำ checklist M1 แล้วบอก "ผ่าน" (รวมถึงบอกว่าหน้าตาไอคอนผ่าน)
- [ ] `git merge --no-ff` จาก `feature/m1-floating-window` เข้า `develop` แล้ว push `develop`
