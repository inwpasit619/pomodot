# 10 — ไอคอนบน Dock: ค่าเริ่มต้น สวิตช์ และสิ่งที่ได้มาด้วย

**Parent:** [map](../map.md)
**Type:** `wayfinder:grilling` (HITL)
**Assignee:** teppasit (agent session)
**Blocked by:** [09 — สลับไอคอนบน Dock ตอนแอพทำงานอยู่ได้ไหม และมีผลอะไรบ้าง](09-research-dock-icon-toggle.md)
**Status:** closed

## Question

สวิตช์แสดง/ซ่อนไอคอนบน Dock อยู่หัวข้อไหนใน Settings ชื่ออะไร ค่าเริ่มต้นแสดงหรือซ่อน Restore Defaults แตะไหม; คลิกไอคอน Dock ทำอะไร (เอาแคปซูลกลับ? ขยายการ์ด?); เมนูแอพด้านบนจอและเมนูคลิกขวาที่ Dock มีคำสั่งอะไรบ้าง; และกล่องบอกครั้งแรกตอนซ่อนแคปซูลต้องพูดถึง Dock ยังไง

**บริบทจาก [ผล research](09-research-dock-icon-toggle.md):** ทำได้และเสี่ยงต่ำ; คลิกไอคอน Dock เอาแคปซูลกลับได้ด้วยโค้ดเดิม; ได้เมนูแอพด้านบนจอ (ควรเพิ่ม `Settings…` ⌘,) และเมนูคลิกขวาที่ Dock ได้; ⌘H ต้องไม่ซ่อนแคปซูล; Dock ไม่ได้ช่วยให้หน้าต่างรับคีย์บอร์ดง่ายขึ้น; ผู้ช่วยแนะนำค่าเริ่มต้น "ปิด"

## Resolution

ตัดสินกับผู้ใช้ 2026-10-17

1. **สวิตช์ `Show in Dock`** อยู่หัวข้อ `General` ใต้ `Open at login` ค่าเริ่มต้น**เปิด** (ผู้ใช้เลือกเปิด แม้ agent แนะนำปิด: เพื่อนที่ไม่คุ้น menu bar เจอแอพง่าย) เก็บใน `settings.json` (key ใหม่ เช่น `showsDockIcon`; ไฟล์ version 1 ที่ไม่มี key นี้ = ค่าเริ่มต้นเปิด) มีผลทันทีไม่ต้องเปิดแอพใหม่ — คนที่อัปเดตจาก 0.9.0 จะเห็นไอคอน Dock โผล่หลังอัปเดต
2. **คลิกไอคอน Dock** = เหมือนเปิดแอพซ้ำ: แคปซูลโผล่ที่เดิมถ้าซ่อนอยู่ และขึ้นหน้าสุด ใช้ `applicationShouldHandleReopen` เดิม **ไม่ขยายเป็นการ์ด**
3. **เมนู:** เมนูแอพด้านบนจอเป็นของมาตรฐาน (`About Pomodot`, `Settings…` ⌘,, Hide, `Quit Pomodot` ⌘Q) — ต้องเพิ่ม `Settings…` เอง; **คลิกขวาที่ไอคอน Dock = เมนูเดียวกับปุ่ม `…` ของการ์ด** (`Today`, `New Cycle…`, `Hide/Show Floating Window`, `Always on Top`, `Statistics…`, `Settings…` …) ส่วน Quit macOS ใส่ให้เอง
4. **`Restore Defaults` คืน `Show in Dock` เป็นเปิด** เหมือนค่าอื่นใน `settings.json`

**จากผล [research](09-research-dock-icon-toggle.md) ที่ต้องใส่ใน spec:** คง `LSUIElement` แล้วตั้ง `.regular` ใน `applicationWillFinishLaunching` (ไม่มีไอคอนแวบตอนปิดสวิตช์); `panel.canHide = false` ให้ ⌘H/Hide ไม่ซ่อนแคปซูล; หลังสลับสวิตช์ให้หน้าต่าง Settings ยังอยู่หน้า (`orderFrontRegardless()`); checklist ทดสอบด้วยมือ: สลับสวิตช์ตอน Pomodot active แล้วเมนูแอพขึ้น/Settings ยังอยู่หน้า, คลิกแคปซูลตอนมีไอคอน Dock ไม่แย่ง focus, Cmd-Tab, คลิก Dock เอาแคปซูลกลับ, คลิกขวาที่ Dock, ⌘H ไม่ซ่อนแคปซูล

**ผลต่อกล่องบอกตอนซ่อนครั้งแรก ([ตั๋ว 03](03-grilling-bring-back-hidden-capsule.md)):** ถ้า `Show in Dock` เปิดอยู่ ข้อความบอกให้คลิกไอคอน Dock ด้วย เช่น "…open Pomodot again from Spotlight or Launchpad, or click its icon in the Dock." (ข้อความจริงเลือกตอนเขียน spec)
