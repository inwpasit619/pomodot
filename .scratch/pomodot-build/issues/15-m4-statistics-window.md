# 15 — M4 · หน้าต่าง Statistics

**Milestone:** M4 · branch `feature/m4-statistics`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M4 › หน้าต่าง Statistics, ตัดวันกับสัปดาห์, M4 › Test (Core) M4 และ A10

**What to build:** เมนู `Statistics…` เปิดหน้าต่างปกติ (ไม่ลอยบนสุด มีปุ่มปิดสีแดง) ที่ขึ้นมาด้านหน้า ในหน้าต่างมีการ์ด 3 ใบเรียงแนวนอน คือ Today / This Week / All Time แต่ละใบมีจำนวน Pomodoro กับเวลา Focus รวม (`2h 05m`, `45m`, `0m`) ข้างล่างเป็นกราฟแท่ง Last 7 Days ที่รวมวันนี้ วันที่ไม่มี Pomodoro ยังมีช่องแต่ไม่มีแท่ง แท่งของวันนี้สีเข้มและวันอื่นสีอ่อนลง ช่องสุดท้ายเขียนว่า `Today` ชี้ที่แท่งแล้วเห็น `8 🍅 · 3h 20m` ถ้าเปิดหน้าต่างค้างไว้ ตัวเลขกับกราฟอัปเดตเองทันทีที่ได้ Pomodoro ใหม่และตอนข้ามเที่ยงคืน วันแรกของสัปดาห์เป็นไปตามการตั้งค่าเครื่อง

**Blocked by:** 14 — บันทึก Pomodoro + `Today: 🍅 N` ในเมนู

**Status:** ready-for-agent

- [ ] test ของ Core (seam 2) เขียนผ่าน `/tdd` จากหัวข้อ Test (Core) M4: This Week เริ่มวันที่ 12 ต.ค. เมื่อ firstWeekday = จันทร์ และ 11 ต.ค. เมื่อ = อาทิตย์, รูปแบบเวลารวมทั้ง 5 กรณี (`1h 15m`, `2h 05m`, `45m`, `0m`, `171h 40m`), กราฟ 7 วันได้ 7 ช่องเสมอโดยช่องที่ไม่มีเป็น 0
- [ ] กราฟใช้ Swift Charts อยู่ในกล่องโค้ง ตัวเลขสถิติใช้ SF Rounded และสไตล์ตาม A10
- [ ] เรียก `NSApp.activate()` ก่อนแสดงหน้าต่าง
- [ ] เมนูมี `Statistics…` ในตำแหน่งตามโครงเมนูสุดท้าย
- [ ] เพิ่มข้อในหมวด Statistics ของ `docs/manual-test.md`: เปิด Statistics ค้างไว้แล้วทำ Pomodoro ครบ 1 อัน → ตัวเลขกับกราฟอัปเดตเอง
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot ของหน้าต่าง Statistics ทั้ง Light และ Dark
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
