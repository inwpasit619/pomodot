# ติดตั้ง CLT ใหม่แล้วตรวจว่า build ผ่าน

Type: task
Label: wayfinder:task
Status: resolved
Assignee: teppasit
Map: [Map: Pomodoro ลอยบนจอ](../map.md)
Blocked by: 04

## Question

ซ่อม Command Line Tools ที่พังตามตั๋ว "ติดตั้ง Xcode หรือใช้แค่ Command Line Tools" แล้วเก็บข้อมูลเวอร์ชันจริงไว้ให้ spec ใช้ toolchain ได้แบบระบุเวอร์ชัน

**HITL: ผู้ใช้ทำ** (ต้องใช้ sudo และต้องกดในหน้าติดตั้ง)
1. `sudo rm -rf /Library/Developer/CommandLineTools`
2. `xcode-select --install` แล้วกด Install
3. บอก agent เมื่อติดตั้งเสร็จ

**AFK: agent ตรวจต่อ**
- `swift --version`, `xcrun --show-sdk-version`, `xcode-select -p`
- ไฟล์เก่าที่ทำให้พัง (`*.private.swiftinterface` ใน `pm/ManifestAPI` และ `usr/include/swift/module.modulemap`) หายไปหรือยัง
- `swift build` package เปล่าๆ ที่มี `platforms: [.macOS(.v14)]` และ import SwiftUI ได้ **โดยไม่ต้องใช้ workaround** จาก research
- `swift test` ด้วย Swift Testing ได้โดยไม่ต้องใส่ flag `-F` เพิ่ม

คำตอบให้บันทึก: เวอร์ชัน Swift / SDK ที่ได้ และ flag พิเศษที่ยังต้องใช้ (ถ้ามี)

## Answer

(ปิดเมื่อ 2026-10-15 ผู้ใช้ติดตั้ง CLT ใหม่ใน Terminal แล้ว agent ตรวจต่อ)

**CLT ใหม่ใช้งานได้ ไม่ต้องใช้ workaround ใดๆ จาก research แล้ว**

- **เวอร์ชันที่ได้:** Apple Swift **6.4** (swiftlang-6.4.0.34.1), macOS SDK **27.0** (มี 26.5 มาด้วย), package `CLTools_Executables` 27.0.0, `xcode-select -p` = `/Library/Developer/CommandLineTools` ตอนนี้มี package receipt แล้ว Software Update จึงอัปเดต CLT ให้ได้ตามปกติ
- **ไฟล์เก่าที่ทำให้พังหายไปหมดแล้ว:** ไม่มี `*.private.swiftinterface` ใน `pm/ManifestAPI` / `pm/PluginAPI` และไม่มี `usr/include/swift/module.modulemap`
- **ลองกับ package ทดสอบ** (`platforms: [.macOS(.v14)]` มี library target + executable ที่ import SwiftUI/AppKit/UserNotifications ใช้ `NSPanel` และมี test target):
  - `swift build` ผ่าน ไม่ต้องใส่ flag เพิ่ม cold build ~42 วินาที
  - `swift test` ผ่านด้วย Swift Testing ไม่ต้องใส่ `-F` เพิ่ม
  - **build universal ในคำสั่งเดียวได้แล้ว:** `swift build -c release --arch arm64 --arch x86_64` ได้ fat binary (x86_64 + arm64) ทั้งสอง arch มี `minos 14.0` ข้อนี้ทำให้ข้อจำกัด "ต้อง build แยกแล้วรวมด้วย `lipo`" ในตั๋ว "ใช้แค่ Command Line Tools สร้าง .app ที่ใช้งานได้จริงไหม" ไม่ใช้แล้ว
- **กติกาที่ต้องใส่ spec เพิ่ม:**
  - Swift 6.4 ใช้ build system ใหม่ ไฟล์ที่ build ออกมาอยู่ที่ `.build/out/Products/<Debug|Release>/` ไม่ใช่ `.build/arm64-apple-macosx/...` แบบเดิม และ build แต่ละ arch จะเขียนทับที่เดียวกัน **script ประกอบ `.app` ต้องหา path ด้วย `swift build ... --show-bin-path` ห้ามเขียน path ตายตัว**
- **warning ที่ไม่ต้องสนใจ:** `ld: warning: search path '.../Developer/usr/lib' not found` และ `The x86_64 architecture is deprecated for your deployment target (macOS 27.0)` (binary จริงยังได้ `minos 14.0`)
- ยังไม่ได้ทดสอบซ้ำบน toolchain ใหม่: การประกอบ `.app` + ad-hoc sign + notification จริง (research ทดสอบบน Swift 6.2.3) ไม่น่ามีอะไรเปลี่ยน เพราะขั้นตอนนี้ใช้ `codesign` ของระบบ ไม่ได้ใช้ toolchain
- ดิสก์ว่างเหลือ ~6.9GB
