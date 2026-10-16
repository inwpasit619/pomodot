# 26 — M6 · ไอคอนบน Dock (`Show in Dock`)

**Milestone:** M6 · branch `feature/m6-without-menu-bar`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M6 › Settings › `General` (`Show in Dock`), M6 › ไอคอนบน Dock, M6 › ข้อมูล, M6 › Test (Core) M6 (Settings, เมนูของการ์ด), M6 › Checklist ทดสอบด้วยมือ M6 › Dock, ภาคผนวก P1 (`settings.json` ฉบับ M6), M1 (ข้อที่ M6 ทับ)

**What to build:** สวิตช์ `Show in Dock` ใน `General` ใต้ `Open at login` ค่าเริ่มต้นเปิด จำไว้ใน `settings.json` มีผลทันที ตอนเปิดไอคอนมะเขือเทศอยู่บน Dock และใน Cmd-Tab คลิกไอคอนแล้วแคปซูลโผล่ขึ้นหน้า คลิกขวาที่ไอคอนได้เมนูเดียวกับเมนูของการ์ด เมนูแอพด้านบนจอมี `Settings…` ⌘, และ ⌘H ไม่ซ่อนแคปซูล `Restore Defaults` คืนสวิตช์เป็นเปิด กล่องตอนซ่อนครั้งแรกพูดถึง Dock เมื่อสวิตช์เปิด

**Blocked by:** 23 — ปุ่ม `…` และเมนูคลิกขวา (เมนู Dock ใช้รายการจาก Core ชุดเดียวกัน), 24 — กล่องบอกตอนซ่อนครั้งแรก (ข้อความแบบมี Dock), 25 — `Open at login` (สร้างหัวข้อ `General`)

**Status:** ready-for-agent

- [ ] Core: `settings.json` key `showInDock` (ไม่มี key = `true`), Restore Defaults → `true` และไม่แตะ state ของ Floating Window; อัปเดต fixture `settings.json` ตาม P1 ฉบับ M6 (test "ไฟล์ค่าเริ่มต้นมี key ตรงกับตัวอย่าง" เปลี่ยนตาม) — test ผ่าน `/tdd` ตามหัวข้อ "Settings" ใน Test (Core) M6
- [ ] App: คง `LSUIElement = true`; ที่เดียวที่เรียก `NSApp.setActivationPolicy(showInDock ? .regular : .accessory)` ใน `applicationWillFinishLaunching` (override เพิ่ม) และทุกครั้งที่ค่าเปลี่ยน แล้ว `orderFrontRegardless()` หน้าต่าง Settings ถ้าเปิดอยู่
- [ ] `panel.canHide = false` เสมอ; คลิกไอคอน Dock ใช้ `applicationShouldHandleReopen` เดิม (ไม่ขยายการ์ด)
- [ ] `applicationDockMenu(_:)` คืนเมนูของการ์ดจาก Core (ไม่มี `Quit Pomodot`) สร้างใหม่ทุกครั้ง; `.commands` บน `MenuBarExtra` เพิ่ม `Settings…` ⌘, (`CommandGroup(replacing: .appSettings)`) ห้ามแทน `NSApp.mainMenu` ด้วยมือ ถ้า `.appSettings` ใช้ไม่ได้ให้หาทางอื่นแล้วบอกในรายงาน
- [ ] กล่อง `Pomodot keeps running` ใช้ข้อความแบบมี Dock เมื่อ `Show in Dock` เปิด
- [ ] `docs/manual-test.md`: แก้ข้อ M1 "ไม่มีไอคอนใน Dock และไม่อยู่ใน Cmd-Tab" ให้เป็น "เฉพาะตอน `Show in Dock` ปิด" และเพิ่มหมวด/ข้อตาม Checklist M6 › Dock (รวมข้อสลับสวิตช์ตอนหน้าต่าง Settings เป็นหน้าต่างที่ใช้อยู่, ⌘H, คลิกขวาที่ Dock)
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot ของ Dock และหน้าต่าง Settings
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
