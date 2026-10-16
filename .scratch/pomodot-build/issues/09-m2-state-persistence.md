# 09 — M2 · จำสถานะข้ามการ Quit (`state.json`)

**Milestone:** M2 · branch `feature/m2-timer`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M2 › ข้อมูล: `state.json` (seam 5), M2 › กติกาของ timer › ปิดแอพแล้วเปิดใหม่, M2 › Floating Window › ตำแหน่งที่จำไว้, M2 › Menu bar (เปิดแอพซ้ำ, จำว่าซ่อนหรือแสดง), M1 › Always on Top, M2 › Test (Core) M2 และภาคผนวก P1

**What to build:** Quit, Force Quit หรือรีสตาร์ทเครื่อง แล้วเปิดแอพใหม่ ได้ Phase, ตัวนับ และเวลาที่เหลือเหมือนเดิม แต่เป็น Paused (ถ้าตอนบันทึกเป็น Ready ก็กลับมาเป็น Ready) ช่วงที่ปิดแอพไว้ไม่นับเวลา ถ้า Force Quit เวลาคลาดได้ไม่เกิน 30 วิ แอพจำตำแหน่งแคปซูล, สถานะซ่อน/แสดง และ Always on Top ไว้ ถ้าตำแหน่งที่จำไว้ไม่อยู่ในจอไหนเลย (เช่น ถอดจอเสริม) แคปซูลกลับไปตำแหน่งเริ่มต้น ถ้าไฟล์อ่านไม่ออก แอพย้ายไฟล์นั้นไว้ข้างๆ แล้วใช้ค่าเริ่มต้นโดยไม่มีกล่องแจ้งเตือน และเปิดแอพซ้ำจาก Finder หรือ Spotlight ตอนรันอยู่ = แสดง Floating Window ไม่ได้เปิดตัวที่สอง

**Blocked by:** 08 — Expected finish

**Status:** ready-for-agent

- [ ] รูปแบบไฟล์และชื่อ key ตาม P1 ส่วน `state.json` แล้ว copy ไฟล์ตัวอย่างไปไว้ที่ `Tests/CoreTests/Fixtures/`
- [ ] Core เป็นคนกำหนดรูปแบบไฟล์, แปลงข้อมูล ↔ JSON, ใช้ค่าเริ่มต้นเมื่อไม่มีไฟล์หรืออ่านไม่ออก (พร้อมบอก App ให้ย้ายไฟล์) และตรวจค่าทีละค่า App แค่รู้ที่อยู่โฟลเดอร์, อ่าน/เขียนแบบ atomic และย้ายไฟล์เสียเป็น `<ชื่อ>.corrupt-<yyyy-MM-dd'T'HH-mm-ss>.json` โดยเขียนลง log ของระบบอย่างเดียว ไม่ใช้ UserDefaults
- [ ] test ของ Core เขียนผ่าน `/tdd`: seam 5 ส่วน state ครบ 7 ข้อในหัวข้อ Test (Core) M2, seam 1 "เปิดแอพใหม่จาก state ที่เป็น Running → Paused" และ seam 4 ตำแหน่งที่จำไว้ (2000,500) → ตำแหน่งเริ่มต้น / (300,400) → ใช้ตำแหน่งนั้น
- [ ] บันทึกเมื่อสถานะเปลี่ยน (ปุ่ม, จบ Phase, auto-pause, ซ่อน/แสดง/ลาก Floating Window, สลับ Always on Top), ทุก 30 วิระหว่าง Running และตอน Quit
- [ ] จำจุดกึ่งกลางของแคปซูลตอนย่อในพิกัดรวมทุกจอของ AppKit (ไม่จำตอนขยาย)
- [ ] เปิดแอพซ้ำแล้วแสดง Floating Window: ลองใช้ `applicationShouldHandleReopen` ก่อน ถ้าใช้กับแอพแบบ `LSUIElement` ไม่ได้ให้หาทางอื่นแล้วบอกในรายงาน
- [ ] เพิ่มข้อ M2 ใน `docs/manual-test.md`: เปิดแอพซ้ำจาก Finder (ตอนซ่อน Floating Window ไว้), Quit กลาง Focus แล้วเปิดใหม่, Force Quit กลาง Focus แล้วเปิดใหม่, ซ่อนแล้ว Quit แล้วเปิดใหม่, ลากไปมุมจอแล้ว Quit แล้วเปิดใหม่, ถอดจอเสริม
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
