# 05 — เขียน M6 ใน spec และหั่นตั๋ว

**Parent:** [map](../map.md)
**Type:** `wayfinder:task` (AFK)
**Assignee:** teppasit (agent session)
**Blocked by:** — (ตั๋ว 01–04, 06–10 ปิดแล้ว)
**Status:** closed

## Question

รวมคำตัดสินทุกใบเป็นหัวข้อ M6 ใน `.scratch/pomodoro-v1/spec.md` (ขอบเขต, หน้าตา, Test (Core), Checklist ทดสอบด้วยมือ, ข้อที่ต้องแก้ใน M1–M5 เดิม เช่น spec/checklist ที่บอกว่าการ์ดมีปุ่ม × และ "คลิกขวาแล้วไม่มีเมนู") แล้วหั่นเป็นตั๋วต่อเลขจาก `.scratch/pomodot-build/issues/` พร้อมด่านปิด milestone และออก 0.10.0

ต้องครอบคลุมด้วย: README (ภาษาอังกฤษ + ไทย) — ปุ่ม `…`/คลิกขวา, วิธีเอาแคปซูลกลับ (เปิดแอพซ้ำ / คลิกไอคอน Dock), เปิดตอน login และการลบรายการค้างตอนถอนการติดตั้ง, สวิตช์ Show in Dock; `settings.json` key ใหม่ใน P1; ข้อตรวจด้วยมือจากผล research ทั้ง 3 ใบ (01, 07, 09)

## Resolution

ทำเสร็จ 2026-10-17

- **Spec:** หัวข้อ **M6. ใช้ได้ครบโดยไม่ต้องแตะ menu bar** ใน [`.scratch/pomodoro-v1/spec.md`](../../pomodoro-v1/spec.md) (เมนูของการ์ด, เอาแคปซูลกลับ, Settings › General, ไอคอนบน Dock, ข้อมูล, Test (Core) M6, Checklist ทดสอบด้วยมือ M6, แจกจ่าย 0.10.0) พร้อมข้อเท็จจริงจาก research ทั้ง 3 ใบสรุปไว้ในตัว; แก้ข้อเก่าที่ M6 ทับแบบขีดฆ่า + หมายเหตุใน A1, A3, A9, M1, M2, M5, P1, P2, P3 และสารบัญ
- **ข้อที่ agent กำหนดเพิ่มตอนเขียน** (ไม่ได้ถามผู้ใช้ เป็นรายละเอียดตามคำตัดสิน): ข้อความจริงของกล่อง `Pomodot keeps running` สองแบบ, key `showInDock` และ `floatingWindow.hideNoticeShown`, `visible` ยังเขียนแต่ไม่ใช้ตอนโหลด, คลิกขวาไม่ขยาย/ลาก/กดปุ่ม, รายการเมนูมาจาก Core ที่เดียวให้เมนู Dock ใช้ร่วม, ข้อความเตือน `Open at login`
- **ตั๋ว implement** ใน [`.scratch/pomodot-build/issues/`](../../pomodot-build/issues/):
  - [23 — ปุ่ม `…` และเมนูคลิกขวาบนแคปซูล/การ์ด](../../pomodot-build/issues/23-m6-card-menu.md)
  - [24 — เปิดแอพแล้วแคปซูลโผล่เสมอ + กล่องบอกตอนซ่อนครั้งแรก](../../pomodot-build/issues/24-m6-capsule-always-shows.md)
  - [25 — Settings › General › `Open at login`](../../pomodot-build/issues/25-m6-open-at-login.md)
  - [26 — ไอคอนบน Dock (`Show in Dock`)](../../pomodot-build/issues/26-m6-show-in-dock.md)
  - [27 — README สำหรับ 0.10.0](../../pomodot-build/issues/27-m6-readme.md)
  - [28 — 🛑 ด่านปิด milestone + ออก `0.10.0`](../../pomodot-build/issues/28-m6-gate-release.md)
- ถึงปลายทางของ map แล้ว: ไม่มีตั๋วเปิดและไม่มีหมอกเหลือ ทางต่อไปคือ `/implement ticket 23`
