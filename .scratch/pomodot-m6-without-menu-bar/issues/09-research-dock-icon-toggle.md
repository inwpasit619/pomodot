# 09 — สลับไอคอนบน Dock ตอนแอพทำงานอยู่ได้ไหม และมีผลอะไรบ้าง

**Parent:** [map](../map.md)
**Type:** `wayfinder:research` (AFK)
**Assignee:** agent
**Blocked by:** —
**Status:** closed

## Question

Pomodot ตอนนี้เป็น `LSUIElement` (ไม่มี Dock icon ไม่มีเมนูแอพด้านบนจอ) และ Floating Window เป็น `NSPanel` แบบ non-activating ผู้ใช้อยากให้แสดงไอคอนบน Dock ได้และเลือกซ่อน/แสดงได้ใน Settings:

1. `NSApp.setActivationPolicy(.regular)` / `.accessory` สลับตอนทำงานอยู่ได้ทันทีไหมโดยไม่ต้องเปิดแอพใหม่ มี glitch ที่รู้กันไหม (หน้าต่างหาย, Dock icon ค้าง, เมนูแอพไม่ขึ้นจนกว่าจะ activate) และตอนเปิดแอพควรตั้งค่าก่อนหรือหลัง `applicationDidFinishLaunching`
2. ตอนเป็น `.regular`: คลิกแคปซูล/การ์ดยังไม่แย่ง focus ไหม, Cmd-Tab เห็น Pomodot, คลิกไอคอน Dock เรียก `applicationShouldHandleReopen` ไหม (จะใช้เอาแคปซูลกลับ), Settings/Statistics/About ขึ้นหน้าสุดและรับคีย์บอร์ดง่ายขึ้นไหม
3. เมนูแอพด้านบนจอที่ได้มา (Pomodot / Edit / Window …) ต้องสร้างเองไหมในแอพ SwiftUI + `MenuBarExtra` และเมนูคลิกขวาที่ไอคอน Dock (`applicationDockMenu`) ใส่คำสั่งเองได้ไหม
4. ไอคอน Dock ใช้ `Pomodot.icns` ใน bundle ได้เลยไหม และจุดเล็กใต้ไอคอน (แอพกำลังทำงาน) แสดงปกติไหม

ทดลองด้วยโค้ดเล็กๆ ที่มี bundle id ของตัวเองถ้าทำได้ ห้ามแตะ Pomodot ที่ผู้ใช้เปิดอยู่

## Resolution

รายละเอียดเต็ม: branch `research/dock-icon-toggle` (local, ห้าม push) ไฟล์ `docs/research/dock-icon-toggle.md` ทดลองด้วย probe `com.example.dockprobe` บน macOS 27

1. **สลับตอนทำงานอยู่ได้** `.regular` ↔ `.accessory` ไอคอนขึ้น/หายใน ~0.5 วินาที หน้าต่างไม่หาย ไม่แย่ง focus สลับเร็วๆ 5 ครั้งไม่มีไอคอนค้าง [ยืนยัน — ตอนแอพ**ไม่** active] ตอนแอพ active (ปกติคือกดจาก Settings) มีรายงานว่าเมนูแอพไม่ขึ้นจนสลับแอพไปกลับ และหน้าต่าง Settings ตกไปข้างหลัง [ยังไม่ได้ทดสอบ → ตรวจด้วยมือ] ตอนเปิดแอพ: คง `LSUIElement` ไว้ แล้วตั้ง `.regular` ใน `applicationWillFinishLaunching` ไอคอนขึ้น ~0.6 วินาที ถ้าปิดสวิตช์ไว้ไม่มีไอคอนแวบ [ยืนยัน 5 ครั้ง]
2. **ตอนมีไอคอน Dock:** `NSApp.activate()` ที่ไม่มีคลิกจริงยังโดนปฏิเสธ — Dock ไม่ได้ทำให้ Settings/Statistics/About รับคีย์บอร์ดง่ายขึ้น [ยืนยัน]; คลิกแคปซูลยังไม่แย่ง focus [เอกสาร, ต้องคลิกจริง]; Cmd-Tab เห็น Pomodot [อนุมาน]; คลิกไอคอน Dock เรียก `applicationShouldHandleReopen` → โค้ดเอาแคปซูลกลับที่มีอยู่ใช้ได้เลย [เอกสาร + ยืนยันด้วย reopen]; **ปัญหาใหม่: ⌘H / Hide Pomodot ซ่อนแคปซูลไปด้วย** แก้ด้วย `panel.canHide = false` [ยืนยัน]
3. **เมนูแอพด้านบนจอ** SwiftUI สร้างให้อยู่แล้ว (Pomodot, Edit, View, Window, Help) [ยืนยันจาก dump] ยังไม่มี `Settings…` ต้องเพิ่มเอง (`CommandGroup(replacing: .appSettings)`) [อนุมาน]; เมนูคลิกขวาที่ไอคอน Dock ใส่คำสั่งได้ด้วย `applicationDockMenu(_:)` [เอกสาร]
4. **ไอคอน** ใช้ `Pomodot.icns` ได้เลย มีจุดใต้ไอคอนตามปกติ [ยืนยัน]

**คำแนะนำของผู้ช่วย (ให้ผู้ใช้ตัดสินในตั๋ว 10):** ค่าเริ่มต้นปิด, ตั้งตอนเปิดแอพและทุกครั้งที่เปลี่ยน, หลังสลับเป็น `.accessory` เรียก `orderFrontRegardless()` กับหน้าต่าง Settings, ตั้ง `panel.canHide = false` เสมอ, ใช้โค้ด reopen เดิม, เพิ่ม `Settings…` (⌘,) ในเมนูแอพ, เมนูคลิกขวาที่ Dock ทำทีหลังได้

**ต้องตรวจด้วยมือใน M6** (รายการ 1–8 ในไฟล์ research): สลับสวิตช์ตอน Pomodot active แล้วเมนูแอพขึ้นไหม / Settings ยังอยู่หน้า, คลิกแคปซูลตอนมี Dock icon ไม่แย่ง focus, Cmd-Tab, คลิกไอคอน Dock เอาแคปซูลกลับ, คลิกขวาไอคอน Dock, ⌘H ไม่ซ่อนแคปซูล
