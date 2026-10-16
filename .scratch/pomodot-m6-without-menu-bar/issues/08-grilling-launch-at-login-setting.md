# 08 — สวิตช์ "เปิดตอน login" อยู่ตรงไหน ค่าเริ่มต้นอะไร

**Parent:** [map](../map.md)
**Type:** `wayfinder:grilling` (HITL)
**Assignee:** —
**Blocked by:** [07 — แอพที่ไม่ได้ notarize เปิดเองตอน login ได้ไหม](07-research-launch-at-login.md)
**Status:** open

## Question

ถ้าทำได้ตามผล research: สวิตช์อยู่หัวข้อไหนในหน้าต่าง Settings ชื่ออะไร ค่าเริ่มต้นเปิดหรือปิด เก็บใน `settings.json` หรืออ่านจากระบบ (ผู้ใช้อาจไปปิดเองใน System Settings) Restore Defaults แตะมันไหม และถ้าระบบต้องให้อนุมัติ จะบอกผู้ใช้ยังไง (เช่น บรรทัดเตือนแบบสิทธิ์ notification)

**บริบทจาก [ผล research](07-research-launch-at-login.md):** ทำได้ด้วย `SMAppService.mainApp` ผู้ใช้ไม่ต้องอนุมัติ อัปเดตทับแล้วยังอยู่ ลบแอพแล้วค้างในรายการ (ผู้ใช้ลบเองได้) ผู้ใช้ไปปิดเองใน System Settings ได้ (`.requiresApproval`) — ต้องตัดสินว่าจะเชื่อค่าใน `settings.json` หรือสถานะจากระบบ และจะลงทะเบียนใหม่เองไหมถ้าหายไป
