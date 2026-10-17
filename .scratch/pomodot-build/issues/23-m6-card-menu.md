# 23 — M6 · ปุ่ม `…` และเมนูคลิกขวาบนแคปซูล/การ์ด

**Milestone:** M6 · branch `feature/m6-without-menu-bar` (ใบนี้แยก branch จาก `develop`)
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M6 › เมนูของการ์ด, M6 › Test (Core) M6 (เมนูของการ์ด, การ์ดไม่หุบระหว่างเมนูเปิด), M6 › Checklist ทดสอบด้วยมือ M6 › Floating Window / เมนูของการ์ด, M2 › Floating Window และ A10

**What to build:** มุมขวาบนของการ์ดเปลี่ยนจากปุ่ม × เป็นปุ่ม `…` กดแล้วเปิดเมนูของการ์ด และคลิกขวา/Control-คลิกที่ใดก็ได้บนแคปซูลหรือการ์ดเปิดเมนูเดียวกัน เมนูมี `Today: 🍅 N` (จาง กดไม่ได้), `New Cycle…`, `Hide Floating Window`, `Always on Top` (✓), `Statistics…`, `Settings…`, `About Pomodot`, `Check for Updates…`, `Quit Pomodot` (ไม่ถามยืนยัน) เปิดเมนูแล้วแอพที่ผู้ใช้พิมพ์อยู่ยังรับคีย์บอร์ด และการ์ดไม่หุบระหว่างเมนูเปิด

**Blocked by:** 22 — M5 · ด่านปิด milestone + ออก `0.9.0` (ผู้ใช้บอก "ผ่าน" M5 แล้วและ merge เข้า `develop` แล้ว ตาม A8 เริ่ม M6 ได้ ข้อตรวจเครื่องเพื่อนของ 0.9.0 ที่ยังค้างอยู่ไม่ต้องรอ)

**Status:** ready-for-agent

- [ ] Core: รายการในเมนูของการ์ด (ชื่อ, กดได้ไหม, เครื่องหมายถูก, คำสั่ง) มาจาก Core ที่เดียว เพื่อให้เมนู Dock ในใบ 26 ใช้ร่วมได้ (เมนู Dock = เมนูนี้ไม่มี `Quit Pomodot`) test ผ่าน `/tdd` ตามหัวข้อ "เมนูของการ์ด" ใน Test (Core) M6
- [ ] Core: `FloatingWindowExpansion` มี `menuOpened()` / `menuClosed(at:)` ระหว่างเมนูเปิดไม่หุบ และนับ 0.5 วิเริ่มจากตอนเมนูปิด test ผ่าน `/tdd` ครบ 4 ข้อในหัวข้อ "การ์ดไม่หุบระหว่างเมนูเปิด"
- [ ] App: `NSMenu` ตัวเดียว `autoenablesItems = false` สร้างใหม่ก่อนเปิดทุกครั้ง ปุ่ม `…` (SF Symbol `ellipsis`, `RoundButtonStyle`, `.reportsButtonFrame()`, `.help("More")`) เรียก `popUp` แบบ async ใต้ปุ่ม; คลิกขวา = `menu(for:)` ใน `FirstClickHostingView`; `menuWillOpen`/`menuDidClose` เรียก Core แล้ว `syncPointer()` + ตั้ง timer ใหม่
- [ ] `FloatingPanel.sendEvent` ไม่ส่ง left-click ที่กด Control ให้ Core; คลิกขวาไม่ขยาย ไม่ลาก ไม่กดปุ่ม
- [ ] ปุ่ม `xmark` บนการ์ดถูกเอาออก คำสั่งทุกอันในเมนูทำงานเหมือนจากเมนู menu bar (New Cycle ใช้กล่องถามเดิม, Statistics/Settings/About ใช้ `showInFront()`/`showAbout()` เดิม) `Quit Pomodot` ไม่ถาม
- [ ] `docs/manual-test.md`: แก้ข้อ M2 ที่พูดถึง "ปุ่มกากบาทมุมขวาบน" และ "คลิกขวาแล้วไม่มีเมนู" ให้ตรงกับ M6 (ใส่ป้าย `(M6)`) และเพิ่มข้อในหมวด Floating Window ตาม Checklist M6 › Floating Window / เมนูของการ์ด (Given/When/Then ภาษาไทย ไม่มีคำสั่ง terminal)
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot ของการ์ดและเมนูที่เปิดอยู่ (ระวังมี Pomodot สองตัว: quit ตัวใน Applications ก่อน)
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
