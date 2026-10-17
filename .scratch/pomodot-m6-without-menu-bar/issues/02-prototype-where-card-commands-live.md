# 02 — คำสั่งที่เหลืออยู่ตรงไหนบนการ์ด

**Parent:** [map](../map.md)
**Type:** `wayfinder:prototype` (HITL)
**Assignee:** teppasit (agent session)
**Blocked by:** [01 — เปิดเมนูจากแคปซูลที่ไม่แย่ง focus ได้ไหม](01-research-menu-from-nonactivating-panel.md)
**Status:** closed

## Question

New Cycle…, Always on Top, Statistics…, Settings…, About Pomodot, Check for Updates… และ Quit Pomodot จะเรียกจากแคปซูล/การ์ดตรงไหน — ปุ่ม `…` บนการ์ดที่เปิดเมนู, คลิกขวาบนแคปซูล/การ์ด (กลับคำตัดสินของ M2), ปุ่มเพิ่มบนการ์ด หรือผสมกัน — ทำ prototype หน้าตาให้ผู้ใช้เลือก โดยให้การ์ดยังดูโล่งตาม A10 และกดผิดยาก

## Resolution

ผู้ใช้เลือก **แบบ B: ปุ่ม `…` แทนปุ่มซ่อน** (2026-10-17)

- มุมขวาบนของการ์ดเหลือปุ่มกลมปุ่มเดียว SF Symbol `ellipsis` (ขนาด/สไตล์เดียวกับปุ่ม `xmark` เดิม) — ปุ่ม `xmark` บนการ์ด**ถูกเอาออก**
- กดแล้วเปิดเมนูใต้ปุ่ม: `New Cycle…` / เส้นคั่น / `Hide Floating Window` / `Always on Top` (✓) / เส้นคั่น / `Statistics…` / `Settings…` / เส้นคั่น / `About Pomodot` / `Check for Updates…` / เส้นคั่น / `Quit Pomodot`
- **คลิกขวา**ที่แคปซูลหรือการ์ดได้เมนูเดียวกัน (กลับคำตัดสินของ M2 ที่ว่าไม่มีเมนูคลิกขวา)
- ปุ่ม Start/Pause/Resume, Reset, Skip และส่วนอื่นของการ์ดเหมือนเดิม
- ผลข้างเคียงที่ผู้ใช้รับรู้: ซ่อนแคปซูลต้องกดสองครั้ง (`…` แล้ว `Hide Floating Window`); Quit ก็สองครั้ง
- วิธีสร้างเมนูตาม [ผล research](01-research-menu-from-nonactivating-panel.md): `NSMenu` ตัวเดียว เปิดจากปุ่มและจาก `menu(for:)` และการ์ดต้องไม่หุบระหว่างเมนูเปิด

Prototype (ทั้ง 4 แบบ): branch `prototype/card-commands` (local, ห้าม push) ไฟล์ `.scratch/pomodot-m6-without-menu-bar/prototypes/card-commands-prototype.html`
