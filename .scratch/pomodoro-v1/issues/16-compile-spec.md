# รวบรวม spec.md

Type: task
Label: wayfinder:task
Status: open
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
