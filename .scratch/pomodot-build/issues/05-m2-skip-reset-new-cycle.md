# 05 — M2 · Skip / Reset / New Cycle + กล่องยืนยัน

**Milestone:** M2 · branch `feature/m2-timer`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M2 › กติกาของ timer › ปุ่ม (Skip, Reset, New Cycle), เปลี่ยน Settings ระหว่างที่ timer เดิน, ถามยืนยัน และ M2 › Test (Core) M2 › Timer

**What to build:** เมนูมี `Skip`, `Reset…`, `New Cycle…` ที่ทำงานตามกติกา Skip ไปที่ Phase ถัดไปตามตารางโดยไม่นับเป็น Pomodoro Reset ทำให้ Phase ปัจจุบันกลับไปเต็มเวลาตาม Settings ล่าสุดแล้วเป็น Ready New Cycle กลับไป Focus 1/N แล้วเป็น Ready กล่องยืนยันขึ้นเฉพาะตอนที่ความคืบหน้าจะหายจริง และต้องขึ้นมาด้านหน้าเสมอแม้ผู้ใช้อยู่ในแอพอื่น ข้อความในกล่องตรงตาม spec ใบนี้ทำกติกาตอนเปลี่ยน Settings ระหว่างที่ timer เดินให้เสร็จใน Core ด้วย แม้หน้า Settings จะมาใน M5 (ตอนนี้แอพใช้ค่าเริ่มต้นไปก่อน)

**Blocked by:** 04 — Timer เดินได้จริง

**Status:** ready-for-agent

- [ ] test ของ Core (seam 1) เขียนผ่าน `/tdd` ครบทุกกรณีต่อไปนี้จากหัวข้อ Test (Core) M2 › Timer: Skip Focus 2/4, Skip Focus 4/4 (ไป Short Break ไม่ใช่ Long Break), Skip Short Break, Skip Long Break (Ready แม้เปิด auto-start Focus), Reset Focus 2/4, Reset หลังเปลี่ยน Focus เป็น 30, New Cycle จาก Short Break 3/4, เปลี่ยน Settings ระหว่างเดินทั้ง 4 กรณี (Focus 30 ตอน Running / ตอน Ready ที่ยังไม่เคย Start, N = 6 ตอน Focus 2/4 / ตอน Focus 1/4 Ready done 0) และกติกาถามยืนยันทั้ง 5 กรณี
- [ ] Phase ถัดไปหลัง Skip ใช้กติกา auto-start เดียวกับตอนหมดเวลาเอง
- [ ] Core เป็นคนบอกว่าต้องถามยืนยันไหม App แค่แสดงกล่อง
- [ ] กล่องยืนยันเรียก `NSApp.activate()` ก่อนแสดง และใช้ข้อความกับปุ่มตามหัวข้อ "ถามยืนยัน" (เวลาใน `It will go back to …` เป็นเวลาจริง)
- [ ] เมนูเรียงตามโครงเมนูสุดท้าย (Start/Pause/Resume, Skip, Reset…, New Cycle…)
- [ ] เพิ่มข้อ M2 ใน `docs/manual-test.md`: เมนูควบคุมได้ครบ, กล่องยืนยัน Reset / New Cycle ขึ้นด้านหน้าเสมอ (ลองตอนอยู่ในแอพอื่น)
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
