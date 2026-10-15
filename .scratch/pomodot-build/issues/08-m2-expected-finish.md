# 08 — M2 · Expected finish

**Milestone:** M2 · branch `feature/m2-timer`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M2 › กติกาของ timer › การแสดงเวลา (Expected finish), M2 › Floating Window (ภาพการ์ด), M2 › Menu bar › เมนู dropdown และ M2 › Test (Core) M2 › Expected finish

**What to build:** การ์ดแสดง `Phase ends` กับ `Cycle ends` และเมนูมี 2 บรรทัดบนสุดที่กดไม่ได้ คือ `Focus 2/4 · ends 14:35` (ใช้ชื่อ Phase จริง เช่น `Short Break 2/4 · ends 14:40`) กับ `Cycle ends 16:10` เวลาทั้งหมดแสดงตามรูปแบบเวลาของเครื่อง (12/24 ชม.) ไม่มีวินาที ตอน Running ค่านิ่ง ตอน Paused หรือ Ready ค่าเลื่อนไปตามเวลาจริง และค่าในเมนูตรงกับบนการ์ดเสมอ

**Blocked by:** 07 — ลากแคปซูล

**Status:** ready-for-agent

- [ ] test ของ Core (seam 1) เขียนผ่าน `/tdd` ครบทั้ง 7 แถวในตาราง Expected finish ของหัวข้อ Test (Core) M2 ค่าที่คาดหวังเอามาจากตารางตรงๆ ห้ามคำนวณซ้ำด้วยสูตรเดียวกับโค้ด
- [ ] Phase ที่ยังไม่เริ่มใช้ความยาวตาม Settings ปัจจุบัน ส่วนจำนวน Focus ที่เหลือใช้ N ของ Cycle ปัจจุบัน
- [ ] เพิ่มข้อ M2 ใน `docs/manual-test.md`: Expected finish ในเมนูตรงกับบนการ์ด
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot ของการ์ดและเมนู
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
