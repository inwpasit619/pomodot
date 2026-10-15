# 18 — M5 · หน้าต่าง Settings ส่วน Timer + Auto-start

**Milestone:** M5 · branch `feature/m5-settings-release` (ใบนี้แยก branch จาก `develop`)
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M5 › หน้าต่าง Settings, M5 › ข้อมูล: `settings.json`, M2 › กติกาของ timer › เปลี่ยน Settings ระหว่างที่ timer เดิน, M5 › Test (Core) M5, ภาคผนวก P1 และ A10

**What to build:** เมนู `Settings…` เปิดหน้าต่างปกติ (ไม่ลอย มีปุ่มปิดสีแดง แยกจาก Statistics) ที่ขึ้นมาด้านหน้า เนื้อหาเป็นฟอร์มหน้าเดียวแบบกล่องมุมโค้งเหมือน System Settings ส่วน **Timer** มี Focus / Short Break / Long Break (1–120 นาที) กับ Pomodoros per Cycle (1–10) เป็นช่องตัวเลขที่มีปุ่มขึ้น/ลง ส่วน **Auto-start** มีสวิตช์ `Start breaks automatically` กับ `Start Focus automatically` และคำอธิบาย `(never after a Long Break)` เปลี่ยนค่าแล้วมีผลทันทีตามกติกาของ M2 โดยไม่มีปุ่ม Save ค่าทุกค่าถูกจำไว้ข้ามการเปิดแอพ ปุ่ม `Restore Defaults` ชิดขวาล่างคืนค่าทุกค่าใน Settings เป็นค่าเริ่มต้น แต่ไม่แตะตำแหน่ง, การซ่อน/แสดง และ Always on Top ของ Floating Window (ส่วน Notifications & Sound กับ Appearance บนหน้าจอมาในใบ 19–20 แต่ไฟล์เก็บทุก key ตั้งแต่ใบนี้)

**Blocked by:** 17 — M4 · ด่านปิด milestone (ผู้ใช้ต้องบอก "ผ่าน" M4 ก่อน)

**Status:** ready-for-agent

- [ ] `settings.json` มีทุก key ตาม P1 (รวม `showNotifications`, เสียง และ `appearance`) และใช้กติการ่วมของไฟล์ บันทึกทุกครั้งที่เปลี่ยน แล้ว copy ไฟล์ตัวอย่างไปไว้ที่ `Tests/CoreTests/Fixtures/`
- [ ] test ของ Core (seam 5 ส่วน settings) เขียนผ่าน `/tdd` ครบ 7 ข้อในหัวข้อ Test (Core) M5: บันทึกแล้วโหลดกลับ, ไม่มีไฟล์ → ค่าเริ่มต้น, ไม่มี `appearance` → System, `focusMinutes` = -5 หรือ 121 → 25, `pomodorosPerCycle` = 0 หรือ 11 → 4, ไฟล์อ่านไม่ออก / version สูงกว่า, ไฟล์ตัวอย่าง P1 และ Restore Defaults ไม่แตะ state ของ Floating Window
- [ ] เปลี่ยนค่าแล้วส่งเข้า Core ผ่านกติกาเปลี่ยน Settings ที่ทำไว้ในใบ 05 (Phase ที่เคย Start แล้วใช้ค่าเดิมจนจบ)
- [ ] ค่า auto-start ที่ผู้ใช้เลือกถูกใช้จริงแทนค่าเริ่มต้นที่ปิดทั้งคู่
- [ ] เรียก `NSApp.activate()` ก่อนแสดงหน้าต่าง สวิตช์และปุ่มสำคัญเป็นสีแดงมะเขือเทศ หัวข้อแต่ละส่วนเป็นตัวเล็กสีเทา
- [ ] **ไม่มี**ปุ่ม "ลบข้อมูลทั้งหมด" หรือ "Show Data Folder" ในแอพ (M5 › ข้อมูลตอนลบ/อัปเดตแอพ)
- [ ] เมนูมี `Settings…` ในตำแหน่งตามโครงเมนูสุดท้าย
- [ ] เพิ่มหมวด Settings ใน `docs/manual-test.md`: เปลี่ยนเวลา / สวิตช์แล้วมีผลทันทีตามกติกา ไม่มีปุ่ม Save, Restore Defaults แล้วค่ากลับเป็นค่าเริ่มต้นโดยแคปซูลไม่ย้าย
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot ของหน้าต่าง Settings
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
