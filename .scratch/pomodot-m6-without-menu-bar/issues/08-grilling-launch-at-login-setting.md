# 08 — สวิตช์ "เปิดตอน login" อยู่ตรงไหน ค่าเริ่มต้นอะไร

**Parent:** [map](../map.md)
**Type:** `wayfinder:grilling` (HITL)
**Assignee:** teppasit (agent session)
**Blocked by:** [07 — แอพที่ไม่ได้ notarize เปิดเองตอน login ได้ไหม](07-research-launch-at-login.md)
**Status:** closed

## Question

ถ้าทำได้ตามผล research: สวิตช์อยู่หัวข้อไหนในหน้าต่าง Settings ชื่ออะไร ค่าเริ่มต้นเปิดหรือปิด เก็บใน `settings.json` หรืออ่านจากระบบ (ผู้ใช้อาจไปปิดเองใน System Settings) Restore Defaults แตะมันไหม และถ้าระบบต้องให้อนุมัติ จะบอกผู้ใช้ยังไง (เช่น บรรทัดเตือนแบบสิทธิ์ notification)

**บริบทจาก [ผล research](07-research-launch-at-login.md):** ทำได้ด้วย `SMAppService.mainApp` ผู้ใช้ไม่ต้องอนุมัติ อัปเดตทับแล้วยังอยู่ ลบแอพแล้วค้างในรายการ (ผู้ใช้ลบเองได้) ผู้ใช้ไปปิดเองใน System Settings ได้ (`.requiresApproval`) — ต้องตัดสินว่าจะเชื่อค่าใน `settings.json` หรือสถานะจากระบบ และจะลงทะเบียนใหม่เองไหมถ้าหายไป

## Resolution

ตัดสินกับผู้ใช้ 2026-10-17

1. **ตำแหน่งและค่าเริ่มต้น:** หัวข้อใหม่ **`General`** อยู่บนสุดของหน้าต่าง Settings (เหนือ `Timer`) มีสวิตช์ **`Open at login`** ค่าเริ่มต้น**ปิด** (ผู้ใช้ต้องเปิดเอง ตามแนวของ Apple) สวิตช์ Dock ในตั๋ว 10 น่าจะอยู่หัวข้อเดียวกัน
2. **สวิตช์แสดงตามความจริงของระบบเสมอ:** อ่านสถานะจาก `SMAppService.mainApp.status` ทุกครั้งที่เปิดหน้าต่าง Settings และตอนแอพกลับมา active (แบบเดียวกับเช็กสิทธิ์ notification) **ไม่เก็บใน `settings.json`** เปิดสวิตช์ = `register()` ปิด = `unregister()` ผู้ใช้เอาออกเองใน System Settings → สวิตช์ปิดตาม แอพ**ไม่ลงทะเบียนกลับเอง** และไม่ลงทะเบียนใหม่ตอนอัปเดต (research: อัปเดตทับแล้วยังอยู่) — ไม่ทำตามคำแนะนำของ research ที่ให้เก็บค่าเองแล้วลงทะเบียนซ้ำ
3. **`Restore Defaults` ไม่แตะ** `Open at login` (เป็นการตั้งค่าของระบบ ไม่อยู่ใน `settings.json` เหมือนตำแหน่งแคปซูลและ Always on Top)
4. **ถ้าระบบต้องให้อนุมัติ (`.requiresApproval`)** ขึ้นบรรทัดสีส้มใต้สวิตช์ แบบเดียวกับเตือนสิทธิ์ notification (SF Symbol `exclamationmark.triangle.fill`) ข้อความราวๆ "Pomodot needs your approval in System Settings to open at login." พร้อมปุ่ม **`Open Login Items…`** ที่เรียก `SMAppService.openSystemSettingsLoginItems()`

สำหรับ README (ตั๋ว 05): บอกวิธีเปิด/ปิดเปิดตอน login, และตอนถอนการติดตั้งให้ปิดสวิตช์ก่อนลบแอพ หรือลบรายการค้างใน System Settings › General › Login Items ด้วยปุ่ม −
