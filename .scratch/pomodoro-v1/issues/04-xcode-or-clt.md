# ติดตั้ง Xcode หรือใช้แค่ Command Line Tools

Type: grilling
Label: wayfinder:grilling
Status: resolved
Assignee: teppasit
Map: [Map: Pomodoro ลอยบนจอ](../map.md)
Blocked by: 01

## Question

จากผลตั๋ว "ใช้แค่ Command Line Tools สร้าง .app ที่ใช้งานได้จริงไหม" จะติดตั้ง Xcode (ฟรี, ประมาณ 10GB+) หรือ build ด้วย SwiftPM + Command Line Tools อย่างเดียว ทางไหนทำให้ agent build, run และแพ็กแอพได้ครบโดยที่ผู้ใช้ไม่ต้องเปิด Xcode เอง (agent แนะนำ ผู้ใช้อนุมัติ)

ข้อมูลเพิ่มจาก research: ทาง CLT-only ใช้ได้ครบสำหรับ v1 แต่ **Command Line Tools บนเครื่องนี้พังอยู่** สิ่งที่ต้องตัดสินจริงๆ คือจะซ่อมด้วยการติดตั้ง CLT ใหม่ (`sudo rm -rf /Library/Developer/CommandLineTools` + `xcode-select --install`) หรือติดตั้ง Xcode ทั้งตัว แล้ว spec จะยึด toolchain ไหน

## Answer

(ปิดเมื่อ 2026-10-15 agent เสนอ ผู้ใช้อนุมัติ)

**ใช้ Command Line Tools อย่างเดียว ไม่ติดตั้ง Xcode** โดยแก้ CLT ที่พังด้วยการติดตั้งใหม่ แล้ว spec ยึดทาง SwiftPM + CLT ตามกติกา build ในตั๋ว "ใช้แค่ Command Line Tools สร้าง .app ที่ใช้งานได้จริงไหม"

- **เหตุผลหลัก:** ดิสก์เครื่อง dev เหลือที่ว่างแค่ 7.6GB (ใช้ไป 99%) แต่ Xcode ต้องใช้ 10GB ขึ้นไป และ research ยืนยันแล้วว่า v1 ไม่ได้ใช้ของที่มีแค่ใน Xcode (Previews, asset catalog, XCTest, build universal ในคำสั่งเดียว, `xcodebuild`)
- **ราคาที่ต้องจ่าย:** spec ต้องมีกติกา build ของทาง CLT (sign ทั้ง bundle, ไม่ใช้ `Bundle.module`, ทำ `.icns` ด้วย `sips` + `iconutil`, ใช้ Swift Testing, ถ้าทำ universal ต้องใช้ `lipo`) ซึ่ง research เขียนไว้ครบแล้ว
- **ขั้นตอนซ่อม (ผู้ใช้ต้องทำเอง เพราะต้องใช้ sudo และต้องกดในหน้าติดตั้ง):** `sudo rm -rf /Library/Developer/CommandLineTools` แล้ว `xcode-select --install` คำสั่งนี้ลบแค่ toolchain ไม่แตะไฟล์อื่น
- ติดตั้งแล้วจะได้ Swift / SDK เวอร์ชันไหนยังไม่รู้ ตั๋ว "ติดตั้ง CLT ใหม่แล้วตรวจว่า build ผ่าน" จะเก็บข้อมูลนี้ไว้
- ข้อสังเกตเพิ่ม: ดิสก์ที่ใกล้เต็มเป็นปัญหาของเครื่อง dev อยู่แล้ว ไม่เกี่ยวกับการเลือกครั้งนี้ ตอน build ต้องใช้พื้นที่ cache อีกหลาย GB
