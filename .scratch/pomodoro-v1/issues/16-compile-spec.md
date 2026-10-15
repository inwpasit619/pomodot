# รวบรวม spec.md

Type: task
Label: wayfinder:task
Status: resolved
Assignee: teppasit
Map: [Map: Pomodoro ลอยบนจอ](../map.md)
Blocked by: 15

## Question

รวบรวมคำตอบของตั๋ว 01–15 ทั้งหมด (และ `CONTEXT.md`) เป็นไฟล์เดียว `.scratch/pomodoro-v1/spec.md` ตาม Destination ของ map ให้ AI coding agent อ่านแล้ว build ได้ครบ 5 milestone โดยไม่ต้องถามผู้ใช้เรื่องที่ตัดสินไปแล้ว

- spec ต้องอ่านจบได้ในตัว แต่ให้ลิงก์กลับไปที่ตั๋วเพื่อให้รู้ที่มาของแต่ละเรื่อง (`.scratch/` ถูก push ขึ้น repo public ด้วย ตามตั๋ว "เลข version และขั้นตอนออก GitHub Release")
- **ใช้ข้อที่ตัดสินทีหลังทับข้อเก่า** ที่รู้อยู่แล้วมีดังนี้:
  - ชื่อแอพคือ `Pomodot` ไม่ใช่ `Pomodoro` (เช่น เมนูต้องเป็น `Quit Pomodot`)
  - ไอคอน menu bar ตอน Pause ไม่บอก Phase (ตั๋ว "ชื่อแอพ, bundle identifier และไอคอน" ทับตั๋ว "menu bar กับหน้าต่างลอย")
  - เมนู dropdown มี `About Pomodot` และ `Check for Updates…` เพิ่ม ก่อน Quit (ตั๋ว "เลข version และขั้นตอนออก GitHub Release")
- ผล research ที่อยู่บน branch `research/*` (ซึ่งไม่ถูก push) ให้ดึงส่วนที่ spec ต้องใช้มาใส่ไว้ใน spec เลย เช่น ขั้นตอนติดตั้งสำหรับ README และกติกา build
- ผู้ใช้อ่านแล้วอนุมัติก่อนปิดตั๋ว

## Answer

(ปิดเมื่อ 2026-10-15 ผู้ใช้อ่านแล้วอนุมัติ advisor ตรวจตัวเลขทุกตัวอย่างและเทียบกับตั๋ว 01–15 แล้ว)

**spec อยู่ที่ [`spec.md`](../spec.md)** (~1,000 บรรทัด)
- **ส่วน A กติกากลาง:** ศัพท์, ตารางเรื่องที่ตัดสินแล้วห้ามถามซ้ำ, toolchain และกติกา build (ดึงมาจาก branch `research/*` แล้ว), โครง repo และ 3 target, Core กับเวลา, การทดสอบ 5 seam, เงื่อนไข "เสร็จ" 7 ข้อ, gitflow และจุดที่ต้องหยุดให้ผู้ใช้ `gh auth login`, หน้าตา
- **ส่วน B มี 5 milestone** แต่ละช่วงมีพฤติกรรม, unit test ที่มีตัวเลขตัวอย่าง และ checklist ทดสอบด้วยมือของตัวเอง
- **ภาคผนวก:** ไฟล์ตัวอย่าง JSON version 1 ทั้ง 3 ไฟล์, ร่าง README อังกฤษ + ไทย, ตารางลิงก์กลับไปที่ตั๋ว และรายการข้อที่ spec ทับของเก่า

**ข้อขัดกันที่ใช้ข้อที่ตัดสินทีหลัง:** ชื่อ Pomodot ทับ Pomodoro ทุกที่, ไอคอนตอน Pause ไม่บอก Phase, เมนูมี About + Check for Updates…, build universal คำสั่งเดียว (ไม่ใช้ `lipo`), macOS ขั้นต่ำ 14, ความยาวใน History เป็นวินาที, executable target ชื่อ `Pomodot`

**ข้อที่ไม่มีในตั๋ว agent เติมเองแล้วผู้ใช้อนุมัติ:**
1. ชื่อ field ในไฟล์ JSON ทั้ง 3 ไฟล์ (ภาคผนวก P1)
2. ตัวเลข `k/N` ตอน Break = เลขของ Focus ก่อนหน้า (Skip Focus 2/4 → Short Break 2/4 → Focus 2/4 อีกรอบ)
3. Skip ใช้สวิตช์ auto-start เหมือนตอนหมดเวลาเอง (หยุดรอเสมอหลัง Long Break)
4. เปลี่ยนจำนวน Pomodoro ต่อ Cycle ตอน Cycle ยังไม่มีความคืบหน้าเลย → ใช้ค่าใหม่ทันที
5. Always on Top เก็บใน `state.json` และ Restore Defaults ไม่แตะ
6. tick ที่มาช้า → Core ไล่ทุก Phase ที่จบแล้ว ใช้เวลาจบตามกำหนด แจ้งเตือนแค่อันล่าสุด
7. ข้อความกล่องยืนยัน Reset / New Cycle
8. SF Symbols ของปุ่มบนการ์ด: `play.fill` / `pause.fill`, `arrow.counterclockwise`, `forward.end.fill`, `xmark`
9. ตำแหน่งเริ่มต้นห่างใต้ menu bar 12 pt, เลื่อนเกิน 3 pt = ลาก, ลากได้แค่ในพื้นที่ใช้งานของจอ
10. เสียง `None` เก็บเป็น `null`, ไม่มี key = ค่าเริ่มต้น

**ขั้นต่อไป (นอก map):** ให้ session ใหม่อ่าน `spec.md` แล้วเริ่ม build M1 ซึ่งต้องหยุดให้ผู้ใช้ `gh auth login` ก่อน push ครั้งแรก
