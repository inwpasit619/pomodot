# 12 — M3 · Banner notification

**Milestone:** M3 · branch `feature/m3-notifications`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M3 › ช่องทาง, ขอสิทธิ์, ข้อความ banner (seam 3), พฤติกรรมของ banner, Test (Core) M3 และ A4 ข้อ 7

**What to build:** Phase ที่หมดเวลาเองจะมี banner ของ macOS ขึ้นพร้อมไอคอนแบบ A และชื่อ `Pomodot` หัวข้อกับเนื้อความตรงตามตาราง และใช้ค่าจริงจาก Settings กับ Cycle banner ขึ้นทุกครั้งแม้ Pomodot เป็นแอพที่ active อยู่ banner ใหม่ทับอันเก่า (Notification Center เหลือแค่อันล่าสุด) คลิก banner แล้ว Floating Window โผล่ขึ้นมาถ้าซ่อนอยู่ banner ไม่มีปุ่ม action แอพขอสิทธิ์ตอนกด Start ครั้งแรกสุด (ไม่ใช่ตอนเปิดแอพ) และ timer เริ่มเดินทันทีโดยไม่รอคำตอบ ถ้าผู้ใช้กด Don't Allow แอพยังใช้ได้ปกติ เสียงยังดัง และไม่มี popup ถามซ้ำ Core รับค่า `Show notifications` มาด้วยแล้ว (ค่าเริ่มต้นเปิด ส่วนสวิตช์มาใน M5) ถ้าปิดจะไม่มี banner แต่เสียงยังดัง

**Blocked by:** 11 — เสียงตอน Phase หมดเวลาเอง

**Status:** ready-for-agent

- [ ] test ของ Core (seam 3) เขียนผ่าน `/tdd` จากหัวข้อ Test (Core) M3: 4 เหตุการณ์ × (เริ่มเอง / รอกด Start) ได้หัวข้อและเนื้อความตรงตาราง, ใช้ค่าจริง (Short Break 7 นาที → `Time for a 7-minute Short Break.` และ N = 6 จบ Focus 6 → `Cycle complete 🍅 6/6`), `Show notifications` ปิด → ไม่มี banner แต่ยังเล่นเสียงช่องที่ถูก
- [ ] ถ้า tick มาช้าจนหลาย Phase จบพร้อมกัน ให้ขึ้น banner เฉพาะของ Phase ล่าสุดที่จบ (A6) ให้ตรงกับกติกาเสียงในใบ 11
- [ ] ขอสิทธิ์ด้วยกล่อง Allow / Don't Allow แบบปกติ **ไม่ใช้ provisional**
- [ ] `UNUserNotificationCenterDelegate` ตอบ `.banner` + `.list` ตอนแอพ active, ทุก banner ใช้ request identifier เดียวกัน, ไม่ใส่เสียงไว้ใน notification
- [ ] ทดสอบ notification โดยเปิดแอพด้วย `open Pomodot.app` เท่านั้น
- [ ] เพิ่มข้อในหมวด Notification & Sound ของ `docs/manual-test.md`: กล่องขอสิทธิ์ขึ้นตอนกด Start ครั้งแรก, banner มีไอคอนและชื่อถูก, banner ขึ้นแม้ Pomodot active อยู่, System Settings › Notifications มีรายการ `Pomodot` พร้อมไอคอน, คลิก banner แล้ว Floating Window โผล่, เปิด Do Not Disturb แล้ว banner ไม่ขึ้นแต่เสียงยังดัง, Don't Allow แล้วเสียงยังดังและไม่มี popup ซ้ำ, Skip / Reset ไม่มี banner
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot ของ banner
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
