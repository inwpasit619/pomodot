# 04 — M2 · Timer เดินได้จริง

**Milestone:** M2 · branch `feature/m2-timer` (ใบนี้แยก branch จาก `develop`)
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ A6, M2 › กติกาของ timer (ลำดับปกติ, ตัวเลข `k/N`, ปุ่ม Start/Pause/Resume, Auto-start, Sleep / ล็อกจอ, การแสดงเวลา), M2 › Menu bar › ไอคอน, M2 › Test (Core) M2 › Timer

**What to build:** กด `Start` ในเมนูแล้ว timer เดิน แคปซูลกับ menu bar นับถอยหลังแบบ `mm:ss` ทุกวินาทีโดยตัวเลขไม่ขยับไปมา บรรทัดเดียวในเมนูเปลี่ยนเป็น `Start` / `Pause` / `Resume` ตามสถานะ ถ้า Paused แคปซูลขึ้น `PAUSED` ถ้า Ready ขึ้น `READY` ถ้า Running จุดเรืองแสงเบาๆ และจุดเป็นสีของ Phase นั้น Phase ที่หมดเวลาเองจะไปต่อตามลำดับปกติ คือ Focus → Short Break → … → Focus N/N → Long Break → Focus 1/N ของ Cycle ใหม่ พร้อมตัวเลข `k/N` ตามกติกา ไอคอน menu bar เปลี่ยนตามตารางสถานะ (`timer` / `cup.and.saucer.fill` / `pause.circle` และเวลาจางลงตอน Paused) ปิดฝาหรือสั่ง Sleep → ตื่นมาเป็น Paused ส่วนล็อกจอแล้ว timer ยังเดินต่อ ใน Core รองรับ auto-start ทั้ง 2 สวิตช์แล้ว แต่ตอนนี้แอพใช้ค่าเริ่มต้นคือปิดทั้งคู่

**Blocked by:** 03 — M1 · ด่านปิด milestone (ผู้ใช้ต้องบอก "ผ่าน" M1 ก่อน)

**Status:** ready-for-agent

- [ ] Core จำแค่ "เริ่มเดินตอนไหน" กับ "ตอนนั้นเหลือกี่วินาที" รับ `now` จากผู้เรียกทุกครั้ง ไม่นับลดทีละวินาที (A6)
- [ ] Phase ที่หมดเวลาใช้เวลาจบตามกำหนด ไม่ใช่เวลาของ tick ที่มาเจอ ถ้า tick มาช้าต้องไล่ทุก Phase ที่จบไปแล้วจนถึง `now` และส่ง Pomodoro ทุกอันที่เกิดขึ้นออกมา
- [ ] test ของ Core (seam 1) เขียนผ่าน `/tdd` ครบทุกกรณีต่อไปนี้จากหัวข้อ Test (Core) M2 › Timer: ลำดับปกติ, Pause/Resume (Pause 09:00 เหลือ 20:00 → Resume 09:10 → 09:15 เหลือ 15:00), Focus ที่ Pause แล้วทำต่อจนครบยังเป็น Pomodoro, tick ที่ 09:25:03 ได้ Pomodoro จบ 09:25:00, auto-start Break, auto-start Focus (Long Break จบแล้วยัง Ready), tick มาช้าตอนเปิด auto-start ทั้งคู่ (09:31 → Focus 2/4 Running เหลือ 24:00), sleep ตอน Running → Paused ไม่มี Pomodoro
- [ ] App ส่ง `tick(now)` ราววินาทีละครั้ง และขอ `ProcessInfo.beginActivity(.userInitiatedAllowingIdleSystemSleep)` ระหว่าง Running
- [ ] App ฟังแค่ `NSWorkspace.willSleepNotification` เพื่อส่ง "sleep ณ now" ให้ Core เท่านั้น ล็อกจอ / จอดับ / screensaver ไม่ส่งอะไร
- [ ] ไอคอนบน menu bar เป็น template image สีเดียวตามตารางในหัวข้อ M2 › Menu bar และเวลาเป็น monospaced digit
- [ ] เพิ่มข้อ M2 ใน `docs/manual-test.md`: ไอคอนกับเวลาบน menu bar ทั้งแบบสีอ่อนและสีเข้ม, เวลาอัปเดตทุกวินาทีโดยตัวเลขไม่ขยับ, ล็อกจอแล้ว timer เดินต่อ, ปิดฝาหรือสั่ง Sleep แล้วตื่นมาเป็น Pause
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
