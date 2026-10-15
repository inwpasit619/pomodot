# 11 — M3 · เสียงตอน Phase หมดเวลาเอง

**Milestone:** M3 · branch `feature/m3-notifications` (ใบนี้แยก branch จาก `develop`)
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M3 › ช่องทาง, M3 › เสียง, A6 (tick ที่มาช้า) และ M3 › Test (Core) M3

**What to build:** Phase ที่หมดเวลาเองจะเล่นเสียงระบบของ macOS ครั้งเดียว ไม่ดังซ้ำ จบ Focus ใช้เสียง **Glass** ส่วนจบ Short Break และ Long Break ใช้เสียง **Hero** (เลือกเปลี่ยนได้ใน M5) Skip, Reset, New Cycle และ auto-pause ตอนเครื่อง sleep ไม่มีเสียง ระหว่าง Focus ก็ไม่มีเสียงติ๊ก ถ้า tick มาช้าจนหลาย Phase จบพร้อมกัน จะดังแค่เสียงของ Phase ล่าสุดที่จบ แอพเล่นเสียงเอง เสียงจึงยังดังแม้ไม่มี notification

**Blocked by:** 10 — M2 · ด่านปิด milestone (ผู้ใช้ต้องบอก "ผ่าน" M2 ก่อน)

**Status:** ready-for-agent

- [ ] Core (seam 3) รับ Phase ที่จบ + วิธีที่จบ แล้วบอกว่าต้องเล่นเสียงไหมและใช้เสียงช่องไหน (ช่อง Focus หรือช่อง Break) App เล่นด้วย `NSSound(named:)` และใช้ความดังของเครื่อง
- [ ] test ของ Core เขียนผ่าน `/tdd` จากหัวข้อ Test (Core) M3: Skip / Reset / New Cycle / auto-pause → ไม่มีเสียง, จบ Focus → ช่อง Focus, จบ Short Break หรือ Long Break → ช่อง Break
- [ ] เพิ่มหมวด Notification & Sound ใน `docs/manual-test.md`: Focus หมดเวลาแล้วได้ยินเสียง Glass, Break หมดแล้วได้ยินเสียง Hero, Skip / Reset ไม่มีเสียง
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
