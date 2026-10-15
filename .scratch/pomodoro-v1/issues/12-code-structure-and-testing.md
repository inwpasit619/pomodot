# spec จะสั่ง agent ให้จัดโครงสร้างโค้ดและทดสอบยังไง

Type: grilling
Label: wayfinder:grilling
Status: open
Map: [Map: Pomodoro ลอยบนจอ](../map.md)
Blocked by: 06, 07

## Question

spec ต้องบอก AI coding agent ว่าจัดโค้ดและพิสูจน์ว่าแอพทำงานถูกยังไง โดยที่ผู้ใช้ไม่ต้องอ่าน Swift (agent เสนอทางที่แนะนำ + trade-off เป็นภาษาคน แล้วให้ผู้ใช้อนุมัติ)

- แบ่ง Swift package เป็น target อะไรบ้าง (เช่น library ที่มี logic ของ timer ล้วนๆ ไม่ import AppKit/SwiftUI แยกจาก executable ที่เป็น UI) เพื่อให้ `swift test` ทดสอบกติกาของ timer ได้โดยไม่ต้องเปิดแอพ
- logic ไหนต้องมี unit test (กติกาจากตั๋ว "กติกาของ timer" เช่น pause/skip/reset, ตัวนับรอบ, Mac sleep) และต้องจำลองเวลา (fake clock) ยังไงให้ test ไม่ต้องรอจริง
- checklist ทดสอบด้วยมือที่ผู้ใช้ทำตามได้เอง: ขึ้นทับแอพ fullscreen, ไม่แย่ง focus, อยู่ทุก Space, menu bar อัปเดตสด, notification + เสียง, เปิดบนเครื่องเพื่อนผ่าน Open Anyway
- เงื่อนไข "เสร็จ" ที่ agent ต้องผ่านก่อนส่งงาน (build universal ผ่าน, test ผ่าน, ไม่มี warning ที่ไม่ได้อธิบาย)

กติกาที่ test ต้องครอบคลุมอยู่ในตั๋ว "กติกาของ timer" ได้แก่ skip ที่ไม่ขยับตัวนับ, auto-start 2 สวิตช์ที่หยุดเสมอหลัง Long Break, auto-pause ตอนเครื่อง sleep (ล็อกจอแล้วไม่หยุด), กลับมาเป็น Pause หลังเปิดแอพใหม่, ค่าจาก Settings มีผลกับ Phase หรือ Cycle ถัดไป, Expected finish

(ส่งต่อมาจากตั๋ว "menu bar กับหน้าต่างลอย เกี่ยวกันยังไง") checklist ทดสอบด้วยมือต้องมี: กล่องยืนยัน Reset/New Cycle ขึ้นมาด้านหน้าเสมอ (แอพไม่มี Dock icon), เปิดแอพซ้ำตอนรันอยู่แล้วแสดง Floating Window, เวลาบน menu bar โชว์เฉพาะตอนเดิน/Pause, ซ่อน Floating Window แล้ว Quit แล้วเปิดใหม่ยังซ่อนอยู่ กติกาถามยืนยันเฉพาะตอนมีของจะหายควรมี unit test

ข้อมูลที่มีแล้ว: CLT + SwiftPM, Swift 6.4, Swift Testing ใช้ได้, minimum macOS 14, หา path ที่ build ด้วย `--show-bin-path`

(ส่งต่อมาจากตั๋ว "แจ้งเตือนกับเสียงตอนหมดเวลา ทำงานยังไง") checklist ทดสอบด้วยมือต้องมี: กล่องขอสิทธิ์ notification ขึ้นตอนกด ▶︎ ครั้งแรก (ไม่ใช่ตอนเปิดแอพ), กด Don't Allow แล้วเสียงยังดังและขึ้นบรรทัดเตือนใน Settings, banner ขึ้นถึงแอพจะเป็นแอพที่ใช้อยู่, คลิก banner แล้ว Floating Window โผล่มา, ตอนเปิด Do Not Disturb เสียงยังดัง, เลือกเสียงใน dropdown แล้วได้ยินทันที ส่วนที่ควรมี unit test: เลือกข้อความ banner ให้ถูกกรณี (4 เหตุการณ์ × เริ่มเอง/รอกด) และไม่แจ้งเตือนตอน Skip / Reset / New Cycle / auto-pause
