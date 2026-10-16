# 01 — เปิดเมนูจากแคปซูลที่ไม่แย่ง focus ได้ไหม

**Parent:** [map](../map.md)
**Type:** `wayfinder:research` (AFK)
**Assignee:** agent
**Blocked by:** —
**Status:** closed

## Question

Floating Window เป็น `NSPanel` แบบ non-activating ที่ห่อ SwiftUI (คลิกแล้วแอพที่ใช้อยู่ยังเป็นแอพ active) ถ้าจะเปิดเมนูคำสั่งจากการ์ด — ด้วยปุ่ม `…` (`NSMenu.popUp(positioning:at:in:)` / SwiftUI `Menu`) หรือคลิกขวา (`.contextMenu` / `menu(for:)`) — แต่ละทาง:

1. เปิดได้ไหมโดย**ไม่ทำให้ Pomodot กลายเป็นแอพ active** (แอพที่พิมพ์อยู่ยังรับคีย์บอร์ด) และใช้งานได้ตอน Pomodot ไม่ active
2. ระหว่างเมนูเปิด การ์ดจะได้รับ mouse exit ไหม (การ์ดหุบเองหลังเมาส์ออกครึ่งวินาที) และกันไม่ให้หุบได้ยังไง
3. รองรับ `Toggle` (เครื่องหมายถูกหน้า Always on Top), เส้นคั่น, ปุ่มที่กดไม่ได้ (greyed out) ไหม
4. ตอนกด item ที่เปิดหน้าต่าง (Settings, Statistics, About) หน้าต่างขึ้นหน้าสุดได้ไหมทั้งที่กดจาก panel ที่ไม่ activate

ตอบจากเอกสาร Apple / แหล่งที่เชื่อถือได้ และถ้าทำได้ ทดลองจริงด้วยโค้ดเล็กๆ บน macOS 14+ แล้วสรุปว่าทางไหนใช้ได้ พร้อมข้อจำกัด

## Resolution

รายละเอียดเต็ม: branch `research/menu-from-nonactivating-panel` (local, ห้าม push) ไฟล์ `docs/research/menu-from-nonactivating-panel.md` ทดลองบน macOS 27.0.1 target macOS 14

1. **เปิดได้โดยไม่แย่ง focus:** `NSMenu.popUp(positioning:at:in:)`, `NSMenu.popUpContextMenu` และ SwiftUI `.contextMenu` เปิดจาก panel ได้ Pomodot ไม่ active แอพเดิมยังอยู่หน้า [ยืนยันด้วยการทดลอง] SwiftUI `Menu` เปิดด้วยโปรแกรมไม่ได้ เลยยืนยันไม่ได้ [อนุมาน]
2. **การ์ดจะหุบระหว่างเมนูเปิด** เพราะ timer เช็กเมาส์ทุก 0.5 วินาทีของ controller (mode `.common`) ยังเดินระหว่างเมนูเปิด [ยืนยัน] ต้องเพิ่มสถานะ "เมนูเปิดอยู่" ใน Core (`FloatingWindowExpansion`) ที่ห้ามหุบ เริ่มนับ 0.5 วินาทีใหม่ตอนเมนูปิด แล้ว `syncPointer()` หนึ่งครั้ง ใช้ `menuWillOpen`/`menuDidClose` (NSMenu) ได้ [ยืนยัน]
3. **เครื่องหมายถูก, เส้นคั่น, ปุ่มเทา:** ได้ครบทั้ง NSMenu และ SwiftUI แม้แอพไม่ active [ยืนยัน] NSMenu ต้องตั้ง `autoenablesItems = false` [เอกสาร]
4. **หน้าต่างที่เปิดจากเมนู:** `orderFrontRegardless()` พาหน้าต่างและ About ขึ้นหน้าสุดได้แม้แอพไม่ active แต่ยังไม่รับคีย์บอร์ด [ยืนยัน] คลิกจริงน่าจะได้ activate เหมือนเมนูบน menu bar [อนุมาน] ถ้าไม่ได้ ผู้ใช้ต้องคลิกหน้าต่างหนึ่งครั้งก่อนพิมพ์

**คำแนะนำ:** `NSMenu` ตัวเดียว เข้าได้สองทาง — ปุ่ม `…` (SwiftUI `Button` ที่เรียก `popUp` แบบ async) และคลิกขวา (`menu(for:)` ใน `FirstClickHostingView`) และเลิกส่ง Control-click ไปที่ Core ใน `FloatingPanel.sendEvent` SwiftUI `Menu` อยู่อันดับท้าย

**ต้องตรวจด้วยมือ (เมาส์จริง) ใน M6:** คลิกขวาจริง, `mouseExited` มาเมื่อไหร่, คลิก item จริงแล้ว Settings รับคีย์บอร์ดเลยไหม, และบน macOS 14/15 ของเพื่อน
