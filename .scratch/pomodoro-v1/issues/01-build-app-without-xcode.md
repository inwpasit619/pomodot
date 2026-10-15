# ใช้แค่ Command Line Tools สร้าง .app ที่ใช้งานได้จริงไหม

Type: research
Label: wayfinder:research
Status: resolved
Map: [Map: Pomodoro ลอยบนจอ](../map.md)
Findings: branch `research/build-app-without-xcode` → `docs/research/build-app-without-xcode.md`

## Question

ถ้ามีแค่ Command Line Tools (Swift 6.2.3, ไม่มี Xcode) บน macOS 27 จะ build แอพ macOS ที่เขียนด้วย SwiftUI/AppKit ด้วย SwiftPM แล้วประกอบเป็น `.app` bundle (มี Info.plist, bundle identifier, ไอคอน, `LSUIElement`) ได้ไหม และแอพนั้นจะ:

- ใช้ `UNUserNotificationCenter` ส่ง notification ได้จริงหรือเปล่า (ต้องมี bundle จริง + ต้อง codesign แบบไหน, ad-hoc `codesign -s -` พอไหม)
- เล่นเสียง, ใช้ `MenuBarExtra` / `NSStatusItem`, และเก็บ `UserDefaults` / ไฟล์ใน Application Support ได้ตามปกติไหม
- มีอะไรบ้างที่ **ต้องใช้ Xcode เท่านั้น** (เช่น asset catalog / `actool`, SwiftUI previews, ทำ `.icns`)

สรุปเป็น: ทาง CLT-only ทำได้ไหม ข้อจำกัดคืออะไร และถ้าติดตั้ง Xcode จะได้อะไรเพิ่ม (รวมถึง build ทาง CLI ด้วย `xcodebuild` ได้ไหม โดยไม่ต้องเปิดหน้า GUI)

## Answer

(ปิดโดย research subagent รายละเอียดและแหล่งอ้างอิงดูที่ branch `research/build-app-without-xcode` ไฟล์ `docs/research/build-app-without-xcode.md` commit ed47357)

- **ไม่ต้องมี Xcode ก็ทำได้** ทดลองบนเครื่องนี้แล้ว build ด้วย `swift build` แล้วประกอบเป็น `.app` เอง และ ad-hoc sign ทำงานได้ครบ: หน้าต่างลอยบนสุด, `MenuBarExtra`, `NSStatusItem`, `LSUIElement`, เสียง, `UserDefaults`, Application Support และ **notification ส่งได้จริงผ่าน `UNUserNotificationCenter`** (ทดสอบด้วย provisional permission) ถ้ารันนอก `.app` จะ crash ทันทีที่เรียก notification
- **Command Line Tools บนเครื่องนี้พัง** มีไฟล์เก่าปี 2023/2024 ค้างอยู่ ทำให้ `swift build` พังทุก package Software Update ช่วยไม่ได้ เพราะไม่มี package receipts **ทางแก้ต้องให้ผู้ใช้ทำเอง:** `sudo rm -rf /Library/Developer/CommandLineTools` แล้ว `xcode-select --install` หรือติดตั้ง Xcode ไปเลยก็แก้ได้เหมือนกัน
- **กติกาที่ต้องเขียนลง spec:**
  - sign ทั้ง `.app` ด้วย `codesign --force -s - App.app` (ไม่ใช้ `--deep` ตอน sign) ถ้า sign แค่ executable จะโดนปฏิเสธสิทธิ์ notification
  - ห้ามใช้ SwiftPM `resources:` / `Bundle.module` ให้ copy ไฟล์ไปไว้ที่ `Contents/Resources` แล้วโหลดด้วย `Bundle.main`
  - ห้ามใช้ `#Preview` กับ `.xcassets` ทำไอคอนเป็น `.icns` ด้วย `sips` + `iconutil`
  - เขียน test ด้วย Swift Testing เพราะใช้ XCTest ไม่ได้
  - ทดสอบ notification ต้องเปิดแอพด้วย `open App.app`
  - ถ้าจะทำ universal binary ให้ build แยกทีละ arch แล้วรวมด้วย `lipo` (ยังไม่ได้รันฝั่ง Intel เพราะไม่ได้ติดตั้ง Rosetta)
- **ถ้าติดตั้ง Xcode จะได้เพิ่ม:** asset catalog/ไอคอนแบบใหม่, Previews, XCTest, universal build ในคำสั่งเดียว และ `xcodebuild` (รันจาก terminal ได้ แต่ต้องมี `.xcodeproj`) ซึ่ง v1 ไม่จำเป็นต้องใช้สักอย่าง
- **ยังไม่ได้ทดสอบ:** หน้าต่างขออนุญาต Allow / Don't Allow แบบปกติ (ต้องมีคนกด) ส่วนการ re-sign แล้วไม่โดนถามสิทธิ์ notification ซ้ำ ทดสอบเฉพาะกับ provisional permission
- หมายเหตุ: ข้อที่บอกว่า "ขั้นต่ำต้อง macOS 15" เป็นของทางที่ใช้ SwiftUI `.windowLevel` ล้วน ซึ่งตั๋ว "หน้าต่างลอยบนสุด + menu bar ทำได้ด้วย API อะไร ต้อง macOS ขั้นต่ำเท่าไหร่" แนะนำให้ใช้ `NSPanel` แทน (ขั้นต่ำ 14) ข้อนี้จะตัดสินในตั๋ว "ต้องรองรับ macOS ต่ำสุดเวอร์ชันไหน"
