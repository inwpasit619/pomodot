# 04 — Today อยู่บนการ์ดตรงไหน

**Parent:** [map](../map.md)
**Type:** `wayfinder:grilling` (HITL)
**Assignee:** teppasit (agent session)
**Blocked by:** [02 — คำสั่งที่เหลืออยู่ตรงไหนบนการ์ด](02-prototype-where-card-commands-live.md)
**Status:** closed

## Question

บรรทัด `Today: 🍅 N` ตอนนี้มีแค่ในเมนู จะแสดงบนการ์ดไหม ตรงไหน หน้าตาแบบไหน (หรือพอแล้วที่เปิด Statistics จากการ์ดได้)

## Resolution

ตัดสินกับผู้ใช้ 2026-10-17

1. **`Today: 🍅 N` เป็นบรรทัดแรกของเมนู `…`** (และเมนูคลิกขวา) สีจาง กดไม่ได้ ตามด้วยเส้นคั่น — แบบเดียวกับเมนูบน menu bar ตัวการ์ดเองไม่เปลี่ยน
2. **เมนูของการ์ดมีแค่ Today + คำสั่งที่การ์ดไม่มี** ไม่ใส่บรรทัดเวลาจบ (`Focus 2/4 · ends …`, `Cycle ends …`) และไม่ใส่ Start/Skip/Reset… เพราะอยู่บนการ์ดแล้ว ผู้ใช้รับได้ว่าคลิกขวาที่แคปซูลตอนย่อจะไม่เห็นเวลาจบ

ลำดับเมนูของการ์ดทั้งหมด (รวมผลจาก [คำสั่งที่เหลืออยู่ตรงไหนบนการ์ด](02-prototype-where-card-commands-live.md)):
`Today: 🍅 N` / — / `New Cycle…` / — / `Hide Floating Window` / `Always on Top` (✓) / — / `Statistics…` / `Settings…` / — / `About Pomodot` / `Check for Updates…` / — / `Quit Pomodot`
