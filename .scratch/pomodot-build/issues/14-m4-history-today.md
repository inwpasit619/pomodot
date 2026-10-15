# 14 — M4 · บันทึก Pomodoro + `Today: 🍅 N` ในเมนู

**Milestone:** M4 · branch `feature/m4-statistics` (ใบนี้แยก branch จาก `develop`)
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M4 › History, ตัดวันกับสัปดาห์, เมนู: `Today: 🍅 5`, M4 › Test (Core) M4, M2 › ข้อมูล (กติการ่วมของทุกไฟล์) และภาคผนวก P1

**What to build:** Pomodoro ทุกอันถูกบันทึกลง History (เวลาจบตามกำหนดแบบ UTC ปัดเป็นวินาที + ความยาวเป็นวินาที) แล้วเก็บไว้ตลอดไป บรรทัดบนสุดของเมนูเป็น `Today: 🍅 N` ที่กดไม่ได้ นับเฉพาะจำนวน Pomodoro ของวันนี้ และกลับเป็น 0 เองตอนเที่ยงคืนตามเวลาเครื่อง (หรือตอนเปลี่ยนโซนเวลา) Quit แล้วเปิดใหม่ตัวเลขยังอยู่ Focus ที่โดน Skip / Reset / New Cycle ไม่ถูกบันทึก และ New Cycle ไม่ลบ History

**Blocked by:** 13 — M3 · ด่านปิด milestone (ผู้ใช้ต้องบอก "ผ่าน" M3 ก่อน)

**Status:** ready-for-agent

- [ ] `history.json` ใช้รูปแบบตาม P1 และกติการ่วมของไฟล์ (atomic, ไฟล์เสียย้ายไว้ข้างๆ, ถ้าบางรายการเสียให้ข้ามแค่รายการนั้น) แล้ว copy ไฟล์ตัวอย่างไปไว้ที่ `Tests/CoreTests/Fixtures/`
- [ ] ตอนจบ Focus **บันทึก History ก่อน state เสมอ**
- [ ] Core รับ `now`, `Calendar` และ `TimeZone` จากผู้เรียก วันใหม่เริ่มตอนเที่ยงคืน และ Pomodoro ที่คร่อมเที่ยงคืนนับเป็นวันที่จบ
- [ ] test ของ Core เขียนผ่าน `/tdd`: seam 2 คือ `2026-10-14T17:10:00Z` (Asia/Bangkok) → นับเป็นวันที่ 15 ต.ค., Focus ที่ Skip / Reset ไม่มี Pomodoro ออกมา, New Cycle ไม่ลบ History และ seam 5 ส่วน history ครบ 6 ข้อในหัวข้อ Test (Core) M4 (รวม 5,000 รายการที่เวลาจบตรงเป๊ะ)
- [ ] App ฟัง `NSCalendarDayChanged` และการเปลี่ยนโซนเวลา เพื่อให้ `Today` เป็น 0 เอง
- [ ] เพิ่มหมวด Statistics ใน `docs/manual-test.md`: ทำ Pomodoro ครบแล้ว `Today` ในเมนูเพิ่มขึ้น, Quit แล้วเปิดใหม่ยังนับครบ, `Today` กลับเป็น 0 ตอนเที่ยงคืน (ถ้าทดสอบด้วยการเปลี่ยนเวลาเครื่อง ให้ทำตอน timer เป็น Ready)
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot ของเมนู
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
