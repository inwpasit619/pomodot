# 30 — M7 · 🛑 ด่านปิด milestone + ออก `0.11.0`

**Milestone:** M7 · `feature/m7-tuck-into-edge` → `develop` → `release/0.11.0` → `main` + tag `v0.11.0`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ A8, A9, M5 › แจกจ่าย, M7 › แจกจ่าย 0.11.0 และ M7 › Checklist ทดสอบด้วยมือ M7

**What to build:** M7 ผ่านแล้ว และเพื่อนอัปเดตจาก 0.10.0 เป็น `Pomodot-0.11.0.zip` จาก `releases/latest` ได้จริง ระหว่างทางผู้ใช้ตรวจและอนุมัติ release notes ก่อนเผยแพร่ (repo public)

**Blocked by:** 29 — การ์ดหุบเข้าขอบ/มุมที่อยู่ใกล้

**Status:** released 2026-10-18 — `v0.11.0` อยู่บน GitHub (`releases/latest`, zip ตรงกับ `dist` ด้วย `shasum -a 256`); เหลือแค่ข้อทดสอบบนเครื่องเพื่อน 🛑 — ระหว่างด่านเจอและแก้ 2 บั๊กบนจอเสริม (การ์ดกระโดดตรงขอบที่ติดจออื่น, แคปซูลชิด menu bar ไม่ได้) ดูหมายเหตุในตั๋ว 29

- [x] ผ่านเงื่อนไข "เสร็จ" ทั้ง 7 ข้อใน A8 (ใช้ `scripts/release.sh --check` ได้สำหรับข้อ 1–5) และ `docs/manual-test.md` มีครบทุกข้อของ Checklist ทดสอบด้วยมือ M7
- [x] รายงานส่งงานภาษาไทย 3 ส่วนตาม A8 ข้อ 7
- [x] 🛑 ถามผู้ใช้ทำ checklist M7 **ทีละข้อ** — ต้องลากด้วยเมาส์จริง; ระวัง Pomodot สองตัว (`dist` กับ Applications) ใช้ข้อมูลชุดเดียวกัน quit ตัวหนึ่งก่อนเปิดอีกตัว — ผู้ใช้บอก "ผ่าน" → ติ๊ก checklist, `/commit-fast`, `git merge --no-ff -m "…"` เข้า `develop` แล้ว push
- [x] แยก `release/0.11.0` จาก `develop`, แก้ `VERSION` เป็น `0.11.0` (commit), ร่าง `docs/release-notes/0.11.0.md` ภาษาอังกฤษ 3 ส่วน (What's new / Fixed, Install or update, Your data is kept) ตามที่ M7 › แจกจ่าย 0.11.0 กำหนด
- [x] 🛑 โชว์ release notes ให้ผู้ใช้ และรอผู้ใช้อนุมัติก่อนเผยแพร่ แล้ว commit ไฟล์นั้นบน `release/0.11.0`
- [x] merge `release/0.11.0` เข้า `main` และกลับเข้า `develop` ด้วย `--no-ff -m` **ไม่สร้าง tag และไม่ push**; ก่อนให้ผู้ใช้รัน ตรวจว่า `git status --porcelain` ว่าง (untracked ก็ทำให้ขั้น 1 หยุด)
- [x] ผู้ใช้รัน `cd ~/Downloads/pomodoro-time && scripts/release.sh docs/release-notes/0.11.0.md` **ใน Terminal ของตัวเอง** แล้วพิมพ์ `yes` (agent พิมพ์แทนไม่ได้ ห้ามปลอม TTY) จากนั้น agent ตรวจซ้ำ: `gh release view v0.11.0` (ไม่ใช่ prerelease, มี zip), `releases/latest` ชี้ `v0.11.0`, ดาวน์โหลดกลับมาเทียบ `shasum -a 256` กับ `dist/Pomodot-0.11.0.zip`, tag อยู่บน GitHub และ `main`/`develop` ตรงกับ `origin`
- [ ] 🛑 ผู้ใช้ทดสอบบนเครื่องเพื่อน: อัปเดตจาก 0.10.0 (ลากทับ → Open Anyway ซ้ำ) แล้ว History/Settings ยังอยู่ และลากการ์ดไปใกล้มุมแล้วหุบเข้ามุม
