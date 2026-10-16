# 09 — สลับไอคอนบน Dock ตอนแอพทำงานอยู่ได้ไหม และมีผลอะไรบ้าง

**Parent:** [map](../map.md)
**Type:** `wayfinder:research` (AFK)
**Assignee:** agent
**Blocked by:** —
**Status:** open

## Question

Pomodot ตอนนี้เป็น `LSUIElement` (ไม่มี Dock icon ไม่มีเมนูแอพด้านบนจอ) และ Floating Window เป็น `NSPanel` แบบ non-activating ผู้ใช้อยากให้แสดงไอคอนบน Dock ได้และเลือกซ่อน/แสดงได้ใน Settings:

1. `NSApp.setActivationPolicy(.regular)` / `.accessory` สลับตอนทำงานอยู่ได้ทันทีไหมโดยไม่ต้องเปิดแอพใหม่ มี glitch ที่รู้กันไหม (หน้าต่างหาย, Dock icon ค้าง, เมนูแอพไม่ขึ้นจนกว่าจะ activate) และตอนเปิดแอพควรตั้งค่าก่อนหรือหลัง `applicationDidFinishLaunching`
2. ตอนเป็น `.regular`: คลิกแคปซูล/การ์ดยังไม่แย่ง focus ไหม, Cmd-Tab เห็น Pomodot, คลิกไอคอน Dock เรียก `applicationShouldHandleReopen` ไหม (จะใช้เอาแคปซูลกลับ), Settings/Statistics/About ขึ้นหน้าสุดและรับคีย์บอร์ดง่ายขึ้นไหม
3. เมนูแอพด้านบนจอที่ได้มา (Pomodot / Edit / Window …) ต้องสร้างเองไหมในแอพ SwiftUI + `MenuBarExtra` และเมนูคลิกขวาที่ไอคอน Dock (`applicationDockMenu`) ใส่คำสั่งเองได้ไหม
4. ไอคอน Dock ใช้ `Pomodot.icns` ใน bundle ได้เลยไหม และจุดเล็กใต้ไอคอน (แอพกำลังทำงาน) แสดงปกติไหม

ทดลองด้วยโค้ดเล็กๆ ที่มี bundle id ของตัวเองถ้าทำได้ ห้ามแตะ Pomodot ที่ผู้ใช้เปิดอยู่
