# 07 — แอพที่ไม่ได้ notarize เปิดเองตอน login ได้ไหม

**Parent:** [map](../map.md)
**Type:** `wayfinder:research` (AFK)
**Assignee:** agent
**Blocked by:** —
**Status:** open

## Question

Pomodot แจกเป็น `.zip` ที่ ad-hoc sign อย่างเดียว (ไม่ notarize, ไม่มี Developer ID) ผู้ใช้กด Open Anyway ครั้งแรก รองรับ macOS 14+ — ถ้าจะให้เปิดเองตอน login:

1. `SMAppService.mainApp.register()` ใช้กับแอพแบบนี้ได้ไหม มีเงื่อนไขอะไร (ต้องอยู่ใน `/Applications`? ต้องผ่าน Open Anyway ก่อน? ผู้ใช้ต้องอนุมัติใน System Settings › General › Login Items ไหม และเช็กสถานะ `.requiresApproval` / `.enabled` ได้ยังไง)
2. อัปเดตด้วยการลากแอพใหม่ไปทับ (ต้องกด Open Anyway ซ้ำ) แล้ว login item ยังอยู่ไหม ยังเปิดได้เองไหม หรือโดน Gatekeeper บล็อกเงียบๆ ตอน login
3. ลบแอพแล้ว login item ค้างไหม ผู้ใช้เอาออกเองได้ยังไง
4. ตอนแอพถูกเปิดโดย login รู้ได้ไหมว่ามาจาก login (เผื่อต้องทำต่างจากเปิดเอง) — ตอนนี้ตัดสินแล้วว่าแคปซูลโผล่เหมือนกัน จึงเป็นข้อมูลประกอบเท่านั้น
5. ทางเลือกอื่นถ้า SMAppService ใช้ไม่ได้ (เช่น ให้ผู้ใช้เพิ่มเองใน Login Items) และข้อเสีย
