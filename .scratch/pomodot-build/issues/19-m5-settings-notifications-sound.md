# 19 — M5 · Settings ส่วน Notifications & Sound

**Milestone:** M5 · branch `feature/m5-settings-release`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M5 › หน้าต่าง Settings (Notifications & Sound), M3 › ขอสิทธิ์ และ M3 › เสียง

**What to build:** หน้า Settings มีส่วน **Notifications & Sound** ที่มีสวิตช์ `Show notifications` (ค่าเริ่มต้นเปิด) ถ้าปิด แอพจะไม่ขอสิทธิ์ ไม่ส่ง banner และไม่โชว์บรรทัดเตือน แต่เสียงยังดัง ถ้าเปิดอยู่แต่ระบบปิดสิทธิ์ notification ของ Pomodot ไว้ จะมีบรรทัดเตือนสีส้มพร้อม SF Symbol `exclamationmark.triangle.fill` ข้อความ `Notifications are turned off for Pomodot in System Settings.` และปุ่ม `Open System Settings…` ที่พาไปหน้า Notifications ของ System Settings มี dropdown `End of Focus sound` กับ `End of Break sound` ที่มี `None` อยู่บนสุดตามด้วยเสียงระบบทุกตัว เลือกแล้วเล่นให้ฟังทันที และเสียงที่เลือกคือเสียงที่ดังตอน Phase หมดเวลา ถ้าเลือก `None` จะเงียบ

**Blocked by:** 18 — หน้าต่าง Settings ส่วน Timer + Auto-start

**Status:** ready-for-agent

- [ ] รายการเสียงมาจากไฟล์ใน `/System/Library/Sounds` (ใช้ชื่อไม่มีนามสกุล) ถ้าชื่อที่บันทึกไว้ไม่มีในเครื่องให้ใช้ค่าเริ่มต้นของช่องนั้น (Glass / Hero) และมี test ของกติกานี้ใน Core (Core รับรายชื่อเสียงที่มีจากผู้เรียก)
- [ ] `None` บันทึกเป็น `null` ตาม P1
- [ ] เช็กสิทธิ์ด้วย `getNotificationSettings` ตอนเปิดหน้าต่างและตอนแอพกลับมา active บรรทัดเตือนขึ้นเฉพาะตอน `Show notifications` เปิดอยู่และระบบปิดสิทธิ์
- [ ] ลองเปิด URL `x-apple.systempreferences:com.apple.Notifications-Settings.extension` จริงก่อนใช้ ถ้าไม่ได้ให้หาทางอื่นแล้วบอกในรายงาน
- [ ] ไม่มีปุ่มเล่นเสียงแยก ไม่มีสวิตช์ปิดเสียงทั้งหมด และไม่มีปุ่มปรับความดัง
- [ ] เพิ่มข้อใน `docs/manual-test.md`: เลือกเสียงแล้วได้ยินทันที, เลือก `None` แล้วหมด Phase ไม่มีเสียง, ระบบปิดสิทธิ์แล้วบรรทัดเตือนสีส้มขึ้นและปุ่มพาไปหน้า Notifications
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
