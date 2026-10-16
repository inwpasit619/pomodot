# 06 — Quit จากเมนูของการ์ดต้องถามยืนยันไหม

**Parent:** [map](../map.md)
**Type:** `wayfinder:grilling` (HITL)
**Assignee:** teppasit (agent session)
**Blocked by:** —
**Status:** closed

## Question

`Quit Pomodot` อยู่ในเมนู `…` / คลิกขวาของการ์ดแล้ว (ต้องกดสองครั้ง) ตอนนี้ Quit จาก menu bar ไม่ถามอะไร และเปิดใหม่ timer กลับมาเป็น Paused ที่เดิม — Quit จากการ์ดควรถามยืนยันไหม (เช่นตอน Focus กำลังเดิน) หรือทำเหมือน menu bar ทุกอย่าง

## Resolution

ตัดสินกับผู้ใช้ 2026-10-17: **ไม่ถามยืนยัน** — `Quit Pomodot` จากเมนูของการ์ดออกทันทีเหมือน Quit จาก menu bar เพราะต้องกดสองครั้งอยู่แล้ว และกดพลาดก็ไม่เสียอะไร (บันทึกสถานะไว้ เปิดใหม่กลับมา Paused ที่เดิม) ทุกทางที่ Quit ได้ — menu bar, เมนูของการ์ด, และ ⌘Q / Quit จาก Dock ถ้าเปิดไอคอน Dock — ทำเหมือนกันหมด
