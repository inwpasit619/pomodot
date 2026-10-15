# 02 — M1 · แคปซูลลอยอยู่บนสุด

**Milestone:** M1 · branch `feature/m1-floating-window`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M1 › Floating Window = `NSPanel` ที่ห่อ SwiftUI view, Always on Top, ตำแหน่งเริ่มต้น, Test (Core) M1, Checklist ทดสอบด้วยมือ M1 และ A10

**What to build:** เปิดแอพครั้งแรกแล้วเห็นแคปซูลกระจก (~128×38 pt) ที่มีจุดสีของ Focus + `25:00` + `READY` อยู่กลางด้านบนใต้ menu bar ของจอหลัก แคปซูลลอยทับทุกแอพ รวมถึงแอพที่เปิดเต็มจอ และตามไปทุก Space คลิกแคปซูลแล้วแอพที่ผู้ใช้กำลังพิมพ์อยู่ยังเป็นแอพที่ active (ไม่แย่ง focus) ในเมนูมี `Hide Floating Window` / `Show Floating Window` และ `✓ Always on Top` ซึ่งค่าเริ่มต้นคือเปิด ปิดแล้วแคปซูลไปอยู่หลังหน้าต่างอื่นได้ทันที เปิดกลับก็ลอยบนสุดทันที (ยังไม่ต้องจำค่านี้ข้ามการเปิดแอพ ส่วนนั้นอยู่ในใบ 09)

**Blocked by:** 01 — โครงแอพที่ build และเปิดได้จริง

**Status:** ready-for-agent

- [ ] test ของ Core (seam 4) เขียนผ่าน `/tdd` ตามหัวข้อ Test (Core) M1: จอหลักมีพื้นที่ใช้งาน (0,0)–(1440,875) และยังไม่มีตำแหน่งที่จำไว้ → จุดกึ่งกลางแคปซูลอยู่ที่ x = 720 และขอบบนอยู่ที่ y = 863 ชื่อ test เป็นประโยค Given/When/Then
- [ ] Floating Window เป็น `NSPanel` ตามโครงที่ research ทดลองแล้วใน spec (borderless + nonactivating, `canBecomeKey`, `collectionBehavior` ครบ 3 ค่า, `hidesOnDeactivate = false`, แสดงด้วย `orderFrontRegardless`)
- [ ] root view ของ SwiftUI มี `.frame` ขนาดตายตัว (กับดักข้อ 1) และ state อยู่ใน model ระดับแอพ ไม่อยู่ใน view ของหน้าต่าง (กับดักข้อ 2)
- [ ] หน้าตาตาม A10: กระจกโปร่งแสงเบลอ, มุมโค้ง, ตัวเลข SF Rounded แบบ `.monospacedDigit()`, จุดสีแดงมะเขือเทศ `#F0524F` และเปลี่ยนตาม Light / Dark ของเครื่อง
- [ ] ตอนนี้จะให้ลากแคปซูลแบบง่ายไปก่อนก็ได้ ส่วนกติกาการลากจริงอยู่ในใบ 07
- [ ] เมนูมี `Hide/Show Floating Window`, `Always on Top`, `Quit Pomodot` เรียงตามโครงเมนูสุดท้ายในหัวข้อ M2 › Menu bar
- [ ] agent เปิดแอพแล้วถ่าย screenshot แคปซูลบนจอ
- [ ] เพิ่มข้อ M1 ที่เหลือใน `docs/manual-test.md`: ตำแหน่งเริ่มต้น, ลอยทับแอพที่ fullscreen, ไม่แย่ง focus, ตามไปทุก Space, สลับ Always on Top, Hide / Show
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน
- [ ] commit ผ่าน `/commit-fast` (ยังไม่ต้อง push)
