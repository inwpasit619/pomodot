# ต้องรองรับ macOS ต่ำสุดเวอร์ชันไหน

Type: grilling
Label: wayfinder:grilling
Status: resolved
Assignee: teppasit
Map: [Map: Pomodoro ลอยบนจอ](../map.md)
Blocked by: 03

## Question

เพื่อนที่จะใช้แอพนี้ใช้ Mac รุ่นไหน macOS เวอร์ชันอะไร แล้วเมื่อเทียบกับตารางในตั๋ว "หน้าต่างลอยบนสุด + menu bar ทำได้ด้วย API อะไร" ควรตั้ง minimum deployment target ไว้ที่ macOS เวอร์ชันไหน (เวอร์ชันต่ำลง = เพื่อนใช้ได้มากขึ้น แต่โค้ดอาจซับซ้อนขึ้น)

## Answer

(ปิดเมื่อ 2026-10-15 คุยกับผู้ใช้)

**ตั้ง minimum macOS ไว้ที่ 14 (Sonoma)**

- **เหตุผล:** ผู้ใช้ยืนยันว่าเพื่อนที่จะใช้แอพไม่มีใครใช้ Mac เก่า (macOS 14 รองรับ Mac ตั้งแต่ราวปี 2018) และ 14 เป็นเวอร์ชันต่ำสุดที่ใช้ API ตามที่แนะนำในตั๋ว "หน้าต่างลอยบนสุด + menu bar ทำได้ด้วย API อะไร" ได้ครบโดยไม่ต้องเขียนทางสำรอง
- **ไม่เลือก 13:** เพื่อนไม่ได้ต้องการ และต้องเขียนโค้ดแบบเก่า (`ObservableObject` แทน `@Observable`, เขียนทางสำรองให้ `NSApp.activate()`)
- **ไม่เลือก 15:** ไม่ได้อะไรเพิ่ม เพราะหน้าต่างลอยใช้ `NSPanel` ไม่ได้ใช้ window API ของ SwiftUI ที่ต้องใช้ 15
- **สิ่งที่ต้องเขียนลง spec:**
  - `Package.swift` ใช้ `platforms: [.macOS(.v14)]` (ทดสอบกับ toolchain ปัจจุบันแล้วในตั๋ว "ติดตั้ง CLT ใหม่แล้วตรวจว่า build ผ่าน" ได้ `minos 14.0`)
  - ใส่ `LSMinimumSystemVersion` = `14.0` ใน `Info.plist` ให้ตรงกัน
  - ใช้ `@Observable` (Observation framework) และ `NSApp.activate()` ได้เลย ห้ามใช้ `activate(ignoringOtherApps:)` ที่ deprecate แล้ว
  - ห้ามใช้ API ที่ต้องใช้ macOS 15 ขึ้นไป ถ้าจำเป็นจริงๆ ต้องครอบด้วย `if #available`
- **ความเสี่ยงที่ยอมรับ:** เครื่อง dev เป็น macOS 27 จึงไม่มีใครทดสอบบน macOS 14 จริง ถ้าเพื่อนเจอปัญหาบนเวอร์ชันเก่า จะรู้ก็ตอนเพื่อนใช้งานแล้ว
