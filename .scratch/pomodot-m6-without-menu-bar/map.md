# Map — ใช้ Pomodot ได้ครบโดยไม่ต้องแตะ menu bar

**Label:** `wayfinder:map`

## Destination

หัวข้อ **M6** ใน [spec](../pomodoro-v1/spec.md) (เขียนแบบ M1–M5: ขอบเขต หน้าตา test checklist ทดสอบด้วยมือ) พร้อมตั๋วให้ `/implement` ทำบน `feature/m6-…` จนออก **0.10.0**: ทุกคำสั่งที่ตอนนี้มีแค่ในเมนูบน menu bar เรียกจากแคปซูล/การ์ดได้ครบ ไอคอน menu bar ยังอยู่เป็นทางเลือก

## Notes

- คุยกับผู้ใช้เป็นภาษาไทย ผู้ใช้ไม่เขียน Swift: agent ตัดสินใจเรื่องเทคนิคแล้วอธิบายข้อดีข้อเสียเป็นภาษาคน
- ใช้ `/grilling` + `/domain-modeling` (ศัพท์ใน `CONTEXT.md`: Floating Window, Phase, Cycle, New Cycle …) และ `/prototype` สำหรับหน้าตา
- กติกากลาง A1–A10 ของ spec ยังใช้ทั้งหมด (Core ไม่ import UI, checklist ทดสอบด้วยมือแบบ Given/When/Then, gitflow)
- ออก 0.9.0 ตามเดิมก่อน งานนี้เป็น 0.10.0 (MINOR = เพิ่มฟีเจอร์)
- ข้อเท็จจริงตอนเริ่ม: บนการ์ดมี Start/Pause/Resume, Reset, Skip, × (ซ่อน), Expected finish; มีแค่ในเมนู: Today, New Cycle…, Always on Top, Statistics…, Settings…, About Pomodot, Check for Updates…, Quit Pomodot; แอพเป็น `LSUIElement` (ไม่มี Dock icon); แคปซูลที่ซ่อนแล้วกลับมาได้จากเมนู, เปิดแอพซ้ำ (Finder/Spotlight) หรือคลิก banner; M2 เคยตัดสินว่าคลิกขวาบนการ์ด "ไม่มีเมนู"

## Decisions so far

<!-- one line per closed ticket -->

- [เปิดเมนูจากแคปซูลที่ไม่แย่ง focus ได้ไหม](issues/01-research-menu-from-nonactivating-panel.md) — ได้: NSMenu (ปุ่ม `…` หรือคลิกขวา) เปิดโดย Pomodot ไม่ active; การ์ดต้องมีสถานะ "เมนูเปิด" ห้ามหุบ; หน้าต่างที่เปิดจากเมนูขึ้นหน้าสุดได้ แต่อาจต้องคลิกหนึ่งครั้งก่อนพิมพ์

## Not yet specified

- Quit จากการ์ด: ต้องถามยืนยันไหม และตำแหน่งของมันกันกดพลาด — ชัดขึ้นเมื่อรู้ว่าคำสั่งอยู่ตรงไหน
- README / ข้อความในแอพที่บอกผู้ใช้ใหม่ว่าทำทุกอย่างจากแคปซูลได้ (มีหรือไม่มี)
- ผลกับ checklist M1–M5 เดิมที่บอกว่า "คลิกขวาแล้วไม่มีเมนู" และ "ไม่มีปุ่ม New Cycle, Quit บนการ์ด" ต้องแก้ตาม

## Out of scope

- คีย์ลัด (⌘, / ⌘Q / global hotkey เรียกแคปซูล) — ผู้ใช้ตัดออกตอนวางขอบเขต และ global hotkey อยู่นอก scope v1 อยู่แล้ว
- ทำให้ Pomodot มีไอคอนบน Dock / เมนูแอพด้านบนจอ — ผู้ใช้เลือกให้แคปซูลเป็นทางเข้าแทน
- สวิตช์ปิดไอคอนบน menu bar — ไม่อยู่ในปลายทางนี้
