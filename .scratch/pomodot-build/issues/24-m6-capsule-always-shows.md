# 24 — M6 · เปิดแอพแล้วแคปซูลโผล่เสมอ + กล่องบอกตอนซ่อนครั้งแรก

**Milestone:** M6 · branch `feature/m6-without-menu-bar`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M6 › เอาแคปซูลกลับ, M6 › ข้อมูล, M6 › Test (Core) M6 (เอาแคปซูลกลับ), ภาคผนวก P1 (`state.json` ฉบับ M6) และ M2 › Menu bar (ข้อที่ M6 ทับ)

**What to build:** เปิด Pomodot เมื่อไหร่แคปซูลโผล่เสมอ แม้ก่อน Quit จะซ่อนไว้ (ตำแหน่งและ Always on Top ยังจำเหมือนเดิม) และครั้งแรกตลอดชีพที่ผู้ใช้ซ่อนแคปซูลจากทางไหนก็ได้ จะมีกล่อง `Pomodot keeps running` บอกวิธีเอากลับ ขึ้นหน้าสุด ปุ่ม `OK` ปุ่มเดียว ไม่ขึ้นอีก

**Blocked by:** 23 — ปุ่ม `…` และเมนูคลิกขวา (การซ่อนย้ายไปอยู่ในเมนูของการ์ด)

**Status:** ready-for-agent

- [ ] Core: โหลด `state.json` แล้ว Floating Window แสดงเสมอ (`visible` ยังเขียนแต่ไม่ใช้) ไม่เพิ่มเลข version; `floatingWindow.hideNoticeShown` (ไม่มี key = `false`) และกติกา "ซ่อนครั้งแรกมีกล่อง ครั้งถัดไปไม่มี"; ข้อความกล่องสองแบบตาม `Show in Dock` (ใบนี้ยังไม่มีสวิตช์ ใช้ค่าจาก Settings ที่ใบ 26 จะเพิ่ม หรือให้ Core รับค่าเป็น parameter ไว้ก่อน) — test ผ่าน `/tdd` ตามหัวข้อ "เอาแคปซูลกลับ"
- [ ] อัปเดต fixture `state.json` ใน `Tests/CoreTests/Fixtures/` ตาม P1 ฉบับ M6
- [ ] App: กล่องเป็น `NSAlert` ขึ้นหน้าสุดแบบเดียวกับกล่องถามยืนยัน (`NSApp.activate()` ก่อน `runModal`) ขึ้นได้จากการซ่อนทุกทาง (เมนูของการ์ด, เมนู menu bar)
- [ ] เปิดซ้ำตอนทำงานอยู่ยังแสดงแคปซูลแบบเดิม (`applicationShouldHandleReopen`) และคลิก banner ยังพาแคปซูลกลับ
- [ ] `docs/manual-test.md`: แก้ข้อ M2 "กด Hide → Quit → เปิดใหม่ → ยังซ่อน" ให้ตรงกับ M6 และเพิ่มข้อตาม Checklist M6 › เอาแคปซูลกลับ
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
