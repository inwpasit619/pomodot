# 28 — M6 · 🛑 ด่านปิด milestone + ออก `0.10.0`

**Milestone:** M6 · `feature/m6-without-menu-bar` → `develop` → `release/0.10.0` → `main` + tag `v0.10.0`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ A8, A9, M5 › แจกจ่าย, M6 › แจกจ่าย 0.10.0 และ M6 › Checklist ทดสอบด้วยมือ M6

**What to build:** M6 ผ่านแล้ว และเพื่อนอัปเดตจาก 0.9.0 เป็น `Pomodot-0.10.0.zip` จาก `releases/latest` ได้จริง ระหว่างทางผู้ใช้ตรวจและอนุมัติ release notes ก่อนเผยแพร่ (repo public)

**Blocked by:** 27 — README สำหรับ 0.10.0

**Status:** ready-for-agent (มีจุดหยุดรอผู้ใช้ 🛑 3 จุด)

- [ ] ผ่านเงื่อนไข "เสร็จ" ทั้ง 7 ข้อใน A8 (ใช้ `scripts/release.sh --check` ได้สำหรับข้อ 1–5) และ `docs/manual-test.md` มีครบทุกข้อของ Checklist ทดสอบด้วยมือ M6
- [ ] รายงานส่งงานภาษาไทย 3 ส่วนตาม A8 ข้อ 7
- [ ] 🛑 ถามผู้ใช้ทำ checklist M6 **ทีละข้อ** (ยกเว้นข้อเครื่องเพื่อน) — ข้อ login จริงต้อง logout/login; ระวัง Pomodot สองตัว (`dist` กับ Applications) ใช้ข้อมูลชุดเดียวกัน quit ตัวหนึ่งก่อนเปิดอีกตัว — ผู้ใช้บอก "ผ่าน" → ติ๊ก checklist, `/commit-fast`, `git merge --no-ff -m "…"` เข้า `develop` แล้ว push
- [ ] แยก `release/0.10.0` จาก `develop`, แก้ `VERSION` เป็น `0.10.0` (commit), ร่าง `docs/release-notes/0.10.0.md` ภาษาอังกฤษ 3 ส่วน (What's new / Fixed, Install or update, Your data is kept) ตามที่ M6 › แจกจ่าย 0.10.0 กำหนด — ต้องบอกว่าไอคอน Dock โผล่หลังอัปเดตและปิดได้ที่ Settings › General › Show in Dock
- [ ] 🛑 โชว์ release notes ให้ผู้ใช้ และรอผู้ใช้อนุมัติก่อนเผยแพร่ แล้ว commit ไฟล์นั้นบน `release/0.10.0`
- [ ] merge `release/0.10.0` เข้า `main` และกลับเข้า `develop` ด้วย `--no-ff -m` **ไม่สร้าง tag และไม่ push** (`release.sh` หยุดถ้ามี tag อยู่แล้ว และสร้าง tag + push `main`/`develop`/tag พร้อมกันเอง); ก่อนให้ผู้ใช้รัน ตรวจว่า `git status --porcelain` ว่าง (untracked ก็ทำให้ขั้น 1 หยุด — ย้ายไฟล์ที่ไม่เกี่ยวไปพักนอก repo แล้วย้ายกลับทีหลัง)
- [ ] ผู้ใช้รัน `cd ~/Downloads/pomodoro-time && scripts/release.sh docs/release-notes/0.10.0.md` **ใน Terminal ของตัวเอง** แล้วพิมพ์ `yes` (agent พิมพ์แทนไม่ได้ ห้ามปลอม TTY) จากนั้น agent ตรวจซ้ำ: `gh release view v0.10.0` (ไม่ใช่ prerelease, มี zip), `releases/latest` ชี้ `v0.10.0`, ดาวน์โหลดกลับมาเทียบ `shasum -a 256` กับ `dist/Pomodot-0.10.0.zip`, tag อยู่บน GitHub และ `main`/`develop` ตรงกับ `origin`
- [ ] 🛑 ผู้ใช้ทดสอบบนเครื่องเพื่อน: อัปเดตจาก 0.9.0 (ลากทับ → Open Anyway ซ้ำ) แล้ว History/Settings ยังอยู่ และไอคอน Dock โผล่; เปิด `Open at login` → อัปเดตทับโดยไม่เปิด → login แล้วเห็นอะไร; ลบแอพแล้วรายการ login ค้างและลบได้ตาม README; บน macOS 14/15 ปุ่ม `…`/คลิกขวาไม่แย่ง focus
