# 22 — M5 · 🛑 ด่านปิด milestone + ออก `0.9.0`

**Milestone:** M5 · `feature/m5-settings-release` → `develop` → `release/0.9.0` → `main` + tag `v0.9.0`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ A8, A9, M5 › แจกจ่าย (เลข version, `scripts/release.sh`, Release notes) และ M5 › Checklist ทดสอบด้วยมือ M5

**What to build:** M5 ผ่านแล้ว และเพื่อนดาวน์โหลด `Pomodot-0.9.0.zip` จาก `releases/latest` ไปติดตั้งและใช้งานได้จริง ระหว่างทางผู้ใช้ได้ตรวจและอนุมัติ release notes ก่อนเผยแพร่ เพราะ repo เป็น public

**Blocked by:** 21 — `release.sh` + README + ทดสอบ Open Anyway ตอนอัปเดต

**Status:** ready-for-agent (มีจุดหยุดรอผู้ใช้ 🛑 3 จุด)

- [ ] ผ่านเงื่อนไข "เสร็จ" ทั้ง 7 ข้อใน A8 และ `docs/manual-test.md` มีครบทุกข้อของ Checklist ทดสอบด้วยมือ M5
- [ ] รายงานส่งงานภาษาไทย 3 ส่วนตาม A8 ข้อ 7 พร้อมผลทดสอบ Open Anyway ตอนอัปเดต
- [ ] 🛑 รอผู้ใช้ทำ checklist M5 (ยกเว้นข้อเครื่องเพื่อน) แล้วบอก "ผ่าน" → `git merge --no-ff` เข้า `develop` แล้ว push
- [ ] แยก `release/0.9.0` จาก `develop`, ตรวจว่า `VERSION` = `0.9.0` แล้วร่าง release notes ภาษาอังกฤษ 3 ส่วน (What's new / Fixed, Install or update, Your data is kept) เขียนเป็นภาษาคน ไม่ใช่ชื่อ commit
- [ ] 🛑 โชว์ release notes ให้ผู้ใช้ และรอผู้ใช้อนุมัติก่อนเผยแพร่
- [ ] merge `release/0.9.0` เข้า `main` ด้วย `--no-ff` + tag `v0.9.0` แล้ว merge กลับเข้า `develop`
- [ ] รัน `scripts/release.sh` ครบทุกขั้น: push `main` + tag + `develop`, `gh release create v0.9.0 Pomodot-0.9.0.zip --title "Pomodot 0.9.0"` โดยไม่ใส่ `--prerelease` แล้วดาวน์โหลดกลับมาเทียบ `shasum -a 256` ให้ตรงกับไฟล์ในเครื่อง
- [ ] 🛑 ผู้ใช้ทดสอบบนเครื่องเพื่อน: ดาวน์โหลดจาก `releases/latest` → ลากไป Applications → Open Anyway → ใช้งานได้
