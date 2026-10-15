# ใช้แค่ Command Line Tools สร้าง .app ที่ใช้งานได้จริงไหม

Type: research
Label: wayfinder:research
Status: open
Map: [Map: Pomodoro ลอยบนจอ](../map.md)
Findings: branch `research/build-app-without-xcode` → `docs/research/build-app-without-xcode.md`

## Question

ถ้ามีแค่ Command Line Tools (Swift 6.2.3, ไม่มี Xcode) บน macOS 27 จะ build แอพ macOS ที่เขียนด้วย SwiftUI/AppKit ด้วย SwiftPM แล้วประกอบเป็น `.app` bundle (มี Info.plist, bundle identifier, ไอคอน, `LSUIElement`) ได้ไหม และแอพนั้นจะ:

- ใช้ `UNUserNotificationCenter` ส่ง notification ได้จริงหรือเปล่า (ต้องมี bundle จริง + ต้อง codesign แบบไหน, ad-hoc `codesign -s -` พอไหม)
- เล่นเสียง, ใช้ `MenuBarExtra` / `NSStatusItem`, และเก็บ `UserDefaults` / ไฟล์ใน Application Support ได้ตามปกติไหม
- มีอะไรบ้างที่ **ต้องใช้ Xcode เท่านั้น** (เช่น asset catalog / `actool`, SwiftUI previews, ทำ `.icns`)

สรุปเป็น: ทาง CLT-only ทำได้ไหม ข้อจำกัดคืออะไร และถ้าติดตั้ง Xcode จะได้อะไรเพิ่ม (รวมถึง build ทาง CLI ด้วย `xcodebuild` ได้ไหม โดยไม่ต้องเปิดหน้า GUI)
