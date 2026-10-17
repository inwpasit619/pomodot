# 29 — M7 · การ์ดหุบเข้าขอบ/มุมที่อยู่ใกล้

**Milestone:** M7 · branch `feature/m7-tuck-into-edge`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M7 › กฎหุบเข้าขอบ, M7 › เรื่องเทคนิค, M7 › Test (Core) M7, M7 › Checklist ทดสอบด้วยมือ M7 และ M2 › การขยายใกล้ขอบจอ (ข้อที่ M7 ทับ)

**What to build:** ปล่อยเมาส์หลังลากการ์ด การ์ดอยู่ที่เดิม แต่แคปซูลย้ายไปชิดขอบ/มุมที่การ์ดอยู่ใกล้ (ไม่ใกล้ = กลางการ์ด) ตอนหุบการ์ดจึงหดเข้าขอบ/มุมนั้น และคลิกขยายอีกครั้งการ์ดออกมาที่เดิม ระยะ "ใกล้" ได้มาจากกฎขยายเดิม ไม่ใช่ตัวเลขตายตัว

**Blocked by:** — (แยก `feature/m7-tuck-into-edge` จาก `develop` ที่มี 0.10.0 แล้ว)

**Status:** ready-for-agent

- [ ] Core: ใน `FloatingWindowExpansion.released` เมื่อเป็นการลากและการ์ดขยายอยู่ → เลือก `CardLayout` ใหม่จากกรอบการ์ดปัจจุบัน แล้วย้าย `capsuleFrame` ไปอยู่ในการ์ดตามทิศนั้น โดย `frame` (การ์ด) เท่าเดิม — กฎหุบต้อง**ถาม `CardLayout(capsule:visibleFrame:)`** ว่าแคปซูลที่ชิดขอบนั้นจะขยายออกจากขอบนั้นไหม **ห้ามเขียน 78 / 81** — test ผ่าน `/tdd` ตามหัวข้อ Test (Core) M7 ค่าที่คาดหวังคำนวณจาก `cardSize` / `capsuleSize` รวม test ไปกลับหลายตำแหน่ง
- [ ] Core: แก้ doc comment ที่บอกว่าทิศไม่เปลี่ยนจนกว่าจะหุบ (`CardLayout`, `cardLayout` ใน `FloatingWindowExpansion`) ให้ตรงกับ M7
- [ ] App: หลัง `released` ถ้าแคปซูลย้าย → ย้าย panel ตาม `panelFrame(around:)` **และ**อัปเดต `display.cardLayout` / `boxFrame` ในรอบเดียวกัน การ์ดต้องไม่กระพริบหรือเลื่อน; `rememberCapsule()` บันทึกตำแหน่งใหม่ (เงื่อนไข `capsuleAtPress != capsuleFrame` ยังจับได้)
- [ ] App: animation หุบหดเข้าทิศใหม่ (`cardLayout` ที่เก็บไว้หลังหุบเป็นของใหม่) และ Reduce motion ยังหุบทันที
- [ ] `docs/manual-test.md`: เพิ่มข้อตาม Checklist M7 แบบ Given/When/Then (ยังไม่ติ๊ก)
- [ ] README อังกฤษ + ไทย: บรรทัด "The card" / "การ์ด" เพิ่มว่าลากการ์ดไปใกล้ขอบหรือมุม แล้วการ์ดหุบเข้าตรงนั้น
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot (แคปซูลอยู่ใน strip ของ menu bar hider ไม่ได้ ดู memory เรื่องถ่าย screenshot Pomodot)
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
