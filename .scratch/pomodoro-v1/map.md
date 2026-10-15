# Map: Pomodoro ลอยบนจอ (macOS, Swift) — v1

Label: wayfinder:map

## Destination

**Spec ของ v1 ที่พร้อม build** (`.scratch/pomodoro-v1/spec.md`) สำหรับแอพ Pomodoro เล็กๆ บน macOS เขียนด้วย Swift มีหน้าต่างลอยอยู่บนสุด ต้องละเอียดพอให้ **AI coding agent ลงมือ build ได้เลย โดยที่ผู้ใช้ไม่ต้องเขียน Swift เอง** และแจกเพื่อนผ่าน GitHub ได้โดยไม่ต้องมี Apple Developer account แบบเสียเงิน

## Notes

- **ผู้ใช้ไม่เขียน Swift และไม่ได้อยากเรียน** — ตั๋วที่เป็นเรื่องเทคนิคให้ปิดด้วย "agent เสนอทางที่แนะนำ + อธิบาย trade-off เป็นภาษาคน" แล้วให้ผู้ใช้อนุมัติ ส่วนตั๋ว HITL ให้คุยเรื่องพฤติกรรมกับหน้าตาของแอพ ไม่ต้องลงรายละเอียด API
- **ไม่มี Apple Developer account แบบเสียเงิน** → ไม่ทำ notarization, ไม่ลง App Store, ไม่ใช้ TestFlight
- เครื่อง dev: macOS 27.0.1, Swift 6.2.3, **มีแค่ Command Line Tools ยังไม่มี Xcode** (จะติดตั้งหรือไม่ รอผลตั๋ว "ติดตั้ง Xcode หรือใช้แค่ Command Line Tools")
- คุยกันเป็นภาษาไทย ศัพท์เทคนิคใช้ภาษาอังกฤษได้
- Skills ที่ใช้: `/grilling`, `/domain-modeling`, `/prototype` (ทำ mock เป็น HTML ได้ ไม่ต้องใช้ Xcode), `/research`
- ผล research เก็บไว้ที่ branch `research/<name>` ไฟล์ `docs/research/<name>.md`
- **ฟีเจอร์ v1 ที่ตกลงกันแล้ว** (ขั้นตอนการ charting):
  - ตั้งเวลาเองได้: focus / short break / long break / จำนวนรอบก่อน long break (ค่าเริ่มต้น 25 / 5 / 15 / 4)
  - แจ้งเตือน + เสียงเมื่อหมดแต่ละช่วง
  - ไอคอนบน menu bar
  - สถิติ/ประวัติ
  - หน้าต่างลอย มีสวิตช์ **เปิด/ปิด always-on-top โดยค่าเริ่มต้นคือเปิด**
  - auto-start ช่วงถัดไป **เป็น option เปิด/ปิดได้**

## Decisions so far

<!-- the index — one line per closed ticket -->

- [เพื่อนเปิดแอพที่ไม่ได้ notarize จาก GitHub ได้ยังไง](issues/02-run-unsigned-app-gatekeeper.md) — แจกฟรีได้: ad-hoc sign ทั้ง bundle แล้วแจกเป็น .zip เพื่อนเปิดผ่าน Privacy & Security › Open Anyway ส่วน Homebrew ใช้ไม่ได้แล้ว
- [หน้าต่างลอยบนสุด + menu bar ทำได้ด้วย API อะไร ต้อง macOS ขั้นต่ำเท่าไหร่](issues/03-floating-window-apis.md) — ใช้ SwiftUI + `MenuBarExtra` + AppKit `NSPanel` ทำหน้าต่างลอย macOS ขั้นต่ำที่แนะนำคือ 14 (ถ้าใช้ SwiftUI ล้วนจะแย่ง focus และขึ้นทับ fullscreen ไม่ได้)

## Not yet specified

- **วิธีเก็บข้อมูลสถิติ** (รูปแบบไฟล์, เก็บย้อนหลังนานแค่ไหน, ลบ/reset ได้ไหม) รอตั๋ว "สถิติ/ประวัติ นับอะไร แสดงยังไง"
- **การ package และแจกจ่าย** ที่เหลืออยู่: เลข version, ขั้นตอนทำ GitHub Release, ทุกครั้งที่อัปเดตต้องกด Open Anyway ใหม่หรือเปล่า (ตกลงกันแล้วว่าใช้ zip + ad-hoc sign ทั้ง bundle และมีขั้นตอนติดตั้งเตรียมไว้ใน research แล้ว)
- **ชื่อแอพและไอคอน**
- **หน้า Settings** (อยู่ตรงไหน หน้าตาแบบไหน) รอตั๋ว "menu bar กับหน้าต่างลอย เกี่ยวกันยังไง"
- **โครงสร้างโค้ดและการทดสอบ** ที่จะเขียนลงใน spec ให้ agent (เช่นแยก logic ของ timer ออกมาให้ test ได้ และมี checklist ทดสอบด้วยมือเรื่องขึ้นทับแอพ fullscreen กับการไม่แย่ง focus) รอเรื่อง toolchain กับ minimum macOS ให้ชัดก่อน

## Out of scope

- iOS / iPadOS (ทำแค่ macOS อย่างเดียว ขั้นตอนการ charting)
- Global hotkey
- ตั้งชื่องานให้แต่ละ pomodoro
- เปิดแอพอัตโนมัติตอน login
- Mac App Store / notarization / Apple Developer account แบบเสียเงิน
