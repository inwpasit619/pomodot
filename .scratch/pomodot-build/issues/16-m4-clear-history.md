# 16 — M4 · Clear History

**Milestone:** M4 · branch `feature/m4-statistics`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M4 › หน้าต่าง Statistics (`Clear History…`), M4 › History และ M4 › Test (Core) M4

**What to build:** ปุ่ม `Clear History…` ชิดขวาล่างของหน้าต่าง Statistics กดแล้วมีกล่องยืนยันแบบ sheet ที่บอกจำนวน คือหัวข้อ `Delete all 412 Pomodoros?` เนื้อความ `This can't be undone.` และปุ่ม `Delete` / `Cancel` ถ้า History ว่างอยู่ปุ่มจะกดไม่ได้ ลบแล้ว History ว่าง ตัวเลข `Today` เป็น 0 แต่ timer ไม่เปลี่ยน (Phase, ตัวนับ และเวลาที่เหลือยังอยู่ครบ)

**Blocked by:** 15 — หน้าต่าง Statistics

**Status:** ready-for-agent

- [ ] test ของ Core เขียนผ่าน `/tdd`: Clear History → History ว่าง, Today = 0 และ state ของ timer ไม่เปลี่ยน
- [ ] ลบแล้วเขียน `history.json` ใหม่ทั้งไฟล์แบบ atomic
- [ ] เพิ่มข้อในหมวด Statistics ของ `docs/manual-test.md`: กล่องยืนยันขึ้นด้านหน้า บอกจำนวนถูก และปุ่มกดไม่ได้ตอน History ว่าง, Clear History แล้ว timer ยังอยู่ที่เดิม
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot ของ sheet
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
