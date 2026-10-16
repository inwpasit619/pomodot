# Map — ใช้ Pomodot ได้ครบโดยไม่ต้องแตะ menu bar

**Label:** `wayfinder:map`

## Destination

หัวข้อ **M6** ใน [spec](../pomodoro-v1/spec.md) (เขียนแบบ M1–M5: ขอบเขต หน้าตา test checklist ทดสอบด้วยมือ) พร้อมตั๋วให้ `/implement` ทำบน `feature/m6-…` จนออก **0.10.0**: ทุกคำสั่งที่ตอนนี้มีแค่ในเมนูบน menu bar เรียกจากแคปซูล/การ์ดได้ครบ ไอคอน menu bar ยังอยู่เป็นทางเลือก

## Notes

- คุยกับผู้ใช้เป็นภาษาไทย ผู้ใช้ไม่เขียน Swift: agent ตัดสินใจเรื่องเทคนิคแล้วอธิบายข้อดีข้อเสียเป็นภาษาคน
- ใช้ `/grilling` + `/domain-modeling` (ศัพท์ใน `CONTEXT.md`: Floating Window, Phase, Cycle, New Cycle …) และ `/prototype` สำหรับหน้าตา
- กติกากลาง A1–A10 ของ spec ยังใช้ทั้งหมด (Core ไม่ import UI, checklist ทดสอบด้วยมือแบบ Given/When/Then, gitflow)
- ออก 0.9.0 ตามเดิมก่อน งานนี้เป็น 0.10.0 (MINOR = เพิ่มฟีเจอร์) — 0.9.0 ออกแล้ว 2026-10-17
- ผู้ใช้ขยายขอบเขตตอนตั๋วเอาแคปซูลกลับ: เปิดตอน login และไอคอน Dock ที่ตั้งค่าได้ อยู่ใน M6 ด้วย (กลับคำ "Dock อยู่นอกขอบเขต")
- ข้อเท็จจริงตอนเริ่ม: บนการ์ดมี Start/Pause/Resume, Reset, Skip, × (ซ่อน), Expected finish; มีแค่ในเมนู: Today, New Cycle…, Always on Top, Statistics…, Settings…, About Pomodot, Check for Updates…, Quit Pomodot; แอพเป็น `LSUIElement` (ไม่มี Dock icon); แคปซูลที่ซ่อนแล้วกลับมาได้จากเมนู, เปิดแอพซ้ำ (Finder/Spotlight) หรือคลิก banner; M2 เคยตัดสินว่าคลิกขวาบนการ์ด "ไม่มีเมนู"

## Decisions so far

<!-- one line per closed ticket -->

- [เปิดเมนูจากแคปซูลที่ไม่แย่ง focus ได้ไหม](issues/01-research-menu-from-nonactivating-panel.md) — ได้: NSMenu (ปุ่ม `…` หรือคลิกขวา) เปิดโดย Pomodot ไม่ active; การ์ดต้องมีสถานะ "เมนูเปิด" ห้ามหุบ; หน้าต่างที่เปิดจากเมนูขึ้นหน้าสุดได้ แต่อาจต้องคลิกหนึ่งครั้งก่อนพิมพ์
- [คำสั่งที่เหลืออยู่ตรงไหนบนการ์ด](issues/02-prototype-where-card-commands-live.md) — แบบ B: ปุ่ม `…` มุมขวาบนแทนปุ่ม × เปิดเมนูคำสั่งทั้งหมด (รวม Hide Floating Window) และคลิกขวาที่แคปซูล/การ์ดได้เมนูเดียวกัน
- [ซ่อนแคปซูลแล้วเอากลับมายังไงโดยไม่ใช้ menu bar](issues/03-grilling-bring-back-hidden-capsule.md) — เปิดแอพเมื่อไหร่แคปซูลโผล่เสมอ (เลิกจำสถานะซ่อนข้าม Quit); ซ่อนครั้งแรกขึ้นกล่องบอกวิธีเอากลับครั้งเดียว + README; ผู้ใช้ขอเพิ่มเปิดตอน login และไอคอน Dock ที่ตั้งค่าได้
- [แอพที่ไม่ได้ notarize เปิดเองตอน login ได้ไหม](issues/07-research-launch-at-login.md) — ได้: `SMAppService.mainApp` ใช้กับแอพ ad-hoc ได้ ไม่ต้องอนุมัติ อัปเดตทับแล้วยังอยู่; ลบแอพแล้วรายการค้าง; login จริงยังต้องตรวจด้วยมือ
- [Today อยู่บนการ์ดตรงไหน](issues/04-grilling-today-on-card.md) — บรรทัดแรกของเมนู `…` (จาง กดไม่ได้) การ์ดไม่เปลี่ยน; เมนูของการ์ดมีแค่ Today + คำสั่งที่การ์ดไม่มี
- [Quit จากเมนูของการ์ดต้องถามยืนยันไหม](issues/06-grilling-quit-from-card.md) — ไม่ถาม ออกทันทีเหมือนทุกทาง Quit อื่น
- [สวิตช์ "เปิดตอน login" อยู่ตรงไหน ค่าเริ่มต้นอะไร](issues/08-grilling-launch-at-login-setting.md) — หัวข้อใหม่ General บนสุด สวิตช์ Open at login ค่าเริ่มต้นปิด แสดงตามสถานะจริงของระบบ ไม่เก็บใน settings.json, Restore Defaults ไม่แตะ, ต้องอนุมัติ → บรรทัดส้ม + ปุ่ม Open Login Items…
- [ไอคอนบน Dock: ค่าเริ่มต้น สวิตช์ และสิ่งที่ได้มาด้วย](issues/10-grilling-dock-icon-setting.md) — `Show in Dock` ใน General ค่าเริ่มต้นเปิด เก็บใน settings.json, Restore Defaults คืนเป็นเปิด; คลิก Dock = แคปซูลโผล่+ขึ้นหน้า; คลิกขวา Dock = เมนูเดียวกับการ์ด; เมนูแอพมาตรฐาน + Settings… ⌘,
- [สลับไอคอนบน Dock ตอนแอพทำงานอยู่ได้ไหม และมีผลอะไรบ้าง](issues/09-research-dock-icon-toggle.md) — ได้ เสี่ยงต่ำ: สลับทันทีโดยคง `LSUIElement`; คลิก Dock เอาแคปซูลกลับด้วยโค้ดเดิม; ต้องกัน ⌘H ซ่อนแคปซูล; สลับตอนแอพ active ยังต้องตรวจด้วยมือ

## Not yet specified

<!-- ไม่มีหมอกเหลือ: README ย้ายเข้าตั๋ว 05 แล้ว -->

## Out of scope

- คีย์ลัด (⌘, / ⌘Q / global hotkey เรียกแคปซูล) — ผู้ใช้ตัดออกตอนวางขอบเขต และ global hotkey อยู่นอก scope v1 อยู่แล้ว
- สวิตช์ปิดไอคอนบน menu bar — ไม่อยู่ในปลายทางนี้
