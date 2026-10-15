# Map: Pomodoro ลอยบนจอ (macOS, Swift) — v1

Label: wayfinder:map

## Destination

**Spec ของ v1 ที่พร้อม build** (`.scratch/pomodoro-v1/spec.md`) สำหรับแอพ Pomodoro เล็กๆ บน macOS เขียนด้วย Swift มีหน้าต่างลอยอยู่บนสุด ต้องละเอียดพอให้ **AI coding agent ลงมือ build ได้เลย โดยที่ผู้ใช้ไม่ต้องเขียน Swift เอง** และแจกเพื่อนผ่าน GitHub ได้โดยไม่ต้องมี Apple Developer account แบบเสียเงิน

## Notes

- **ผู้ใช้ไม่เขียน Swift และไม่ได้อยากเรียน** — ตั๋วที่เป็นเรื่องเทคนิคให้ปิดด้วย "agent เสนอทางที่แนะนำ + อธิบาย trade-off เป็นภาษาคน" แล้วให้ผู้ใช้อนุมัติ ส่วนตั๋ว HITL ให้คุยเรื่องพฤติกรรมกับหน้าตาของแอพ ไม่ต้องลงรายละเอียด API
- **ไม่มี Apple Developer account แบบเสียเงิน** → ไม่ทำ notarization, ไม่ลง App Store, ไม่ใช้ TestFlight
- เครื่อง dev: macOS 27.0.1, **ใช้แค่ Command Line Tools ไม่ติดตั้ง Xcode** (ตัดสินแล้ว) ติดตั้ง CLT ใหม่แล้ว: Swift 6.4, SDK 27.0 ดิสก์เหลือที่ว่างน้อย (~7GB)
- คุยกันเป็นภาษาไทย ศัพท์เทคนิคใช้ภาษาอังกฤษได้
- Skills ที่ใช้: `/grilling`, `/domain-modeling`, `/prototype` (ทำ mock เป็น HTML ได้ ไม่ต้องใช้ Xcode), `/research`
- ผล research เก็บไว้ที่ branch `research/<name>` ไฟล์ `docs/research/<name>.md`
- **ฟีเจอร์ v1 ที่ตกลงกันแล้ว** (ขั้นตอนการ charting):
  - ตั้งเวลาเองได้: focus / short break / long break / จำนวนรอบก่อน long break (ค่าเริ่มต้น 25 / 5 / 15 / 4)
  - แจ้งเตือน + เสียงเมื่อหมดแต่ละช่วง (รายละเอียดในตั๋ว "แจ้งเตือนกับเสียงตอนหมดเวลา")
  - ไอคอนบน menu bar
  - สถิติ/ประวัติ
  - หน้าต่างลอย มีสวิตช์ **เปิด/ปิด always-on-top โดยค่าเริ่มต้นคือเปิด**
  - auto-start ช่วงถัดไป **เป็น option เปิด/ปิดได้** (แยกเป็น 2 สวิตช์: Break / Focus)
  - แสดง **Expected finish** คือเวลาจบของ Phase ปัจจุบันและของ Cycle (เพิ่มในตั๋ว "กติกาของ timer")
  - แอพบน menu bar ไม่มี Dock icon, UI ภาษาอังกฤษ (ตั๋ว "menu bar กับหน้าต่างลอย")
  - **ผู้ใช้อยากได้ UI แบบ modern** (บอกไว้ 2026-10-15) ใช้กับทุกหน้าจอ ทั้ง Floating Window, เมนู, Settings และสถิติ ตัดสินแล้วในตั๋ว "หน้าตาและตำแหน่งของหน้าต่างลอย" ได้แก่ กระจกโปร่งแสง, มุมโค้ง, SF Rounded, สีประจำ Phase, รองรับ light/dark และมีตัวเลือก Appearance System/Light/Dark
  - ศัพท์ของ domain อยู่ใน `CONTEXT.md` ที่ root (Phase, Pomodoro, Cycle, Reset, New Cycle ฯลฯ)

## Decisions so far

<!-- the index — one line per closed ticket -->

- [ใช้แค่ Command Line Tools สร้าง .app ที่ใช้งานได้จริงไหม](issues/01-build-app-without-xcode.md) — ได้ ทดสอบแล้วครบรวมถึง notification แต่ CLT บนเครื่องนี้พังอยู่ ต้องติดตั้งใหม่ และมีกติกา build ที่ต้องใส่ใน spec
- [เพื่อนเปิดแอพที่ไม่ได้ notarize จาก GitHub ได้ยังไง](issues/02-run-unsigned-app-gatekeeper.md) — แจกฟรีได้: ad-hoc sign ทั้ง bundle แล้วแจกเป็น .zip เพื่อนเปิดผ่าน Privacy & Security › Open Anyway ส่วน Homebrew ใช้ไม่ได้แล้ว
- [หน้าต่างลอยบนสุด + menu bar ทำได้ด้วย API อะไร ต้อง macOS ขั้นต่ำเท่าไหร่](issues/03-floating-window-apis.md) — ใช้ SwiftUI + `MenuBarExtra` + AppKit `NSPanel` ทำหน้าต่างลอย macOS ขั้นต่ำที่แนะนำคือ 14 (ถ้าใช้ SwiftUI ล้วนจะแย่ง focus และขึ้นทับ fullscreen ไม่ได้)
- [ติดตั้ง Xcode หรือใช้แค่ Command Line Tools](issues/04-xcode-or-clt.md) — ใช้ CLT + SwiftPM อย่างเดียว ไม่ลง Xcode (ดิสก์ไม่พอ และ v1 ไม่ต้องใช้) ซ่อม CLT ด้วยการติดตั้งใหม่
- [ติดตั้ง CLT ใหม่แล้วตรวจว่า build ผ่าน](issues/11-reinstall-clt-verify.md) — ได้ Swift 6.4 / SDK 27.0 build กับ test ผ่านโดยไม่ต้องใช้ workaround build universal ในคำสั่งเดียวได้แล้ว และ spec ต้องหา path ของไฟล์ที่ build ด้วย `--show-bin-path`
- [ต้องรองรับ macOS ต่ำสุดเวอร์ชันไหน](issues/05-minimum-macos.md) — macOS 14 (Sonoma) เพื่อนไม่มีใครใช้ Mac เก่า และใช้ API ที่แนะนำได้ครบโดยไม่ต้องเขียนทางสำรอง
- [กติกาของ timer: pause, skip, reset, Mac sleep และ auto-start](issues/06-timer-rules.md) — Pomodoro = Focus ที่ทำครบ, skip Focus ตัวนับไม่ขยับ, เครื่อง sleep แล้ว auto-pause, auto-start มี 2 สวิตช์และหยุดเสมอหลัง Long Break, เปิดแอพใหม่กลับมาเป็น Pause, มี Expected finish ของ Phase และ Cycle
- [menu bar กับหน้าต่างลอย เกี่ยวกันยังไง](issues/07-menubar-vs-floating.md) — แอพบน menu bar ไม่มี Dock icon, menu bar โชว์เวลาตอนเดิน/Pause, คลิกได้เมนู dropdown ที่ควบคุมได้ครบ, ปิด Floating Window = ซ่อน, Always on Top อยู่ในเมนู, Settings กับสถิติเป็นหน้าต่างแยก, ถามยืนยันก่อน Reset/New Cycle, UI ภาษาอังกฤษ
- [แจ้งเตือนกับเสียงตอนหมดเวลา ทำงานยังไง](issues/08-notification-and-sound.md) — banner + เสียงระบบดังครั้งเดียวเฉพาะตอนหมดเวลาเอง แอพเล่นเสียงเองเลยยังดังตอน Do Not Disturb เลือกเสียงได้ (ค่าเริ่มต้น Glass/Hero) ขอสิทธิ์ตอนกด ▶︎ ครั้งแรก คลิก banner = แสดง Floating Window
- [สถิติ/ประวัติ นับอะไร แสดงยังไง](issues/09-what-stats-mean.md) — History เก็บแค่ Pomodoro (เวลาจบ + ความยาว) ไว้ตลอดไป, เมนูโชว์ `Today: 🍅 n`, หน้าต่าง Statistics มีการ์ด Today/Week/All Time + กราฟ 7 วัน + `Clear History…`, ตัดวันตอนเที่ยงคืนตามวันที่จบ
- [หน้าตาและตำแหน่งของหน้าต่างลอย](issues/10-floating-window-look.md) — แคปซูลกระจกเล็กๆ (จุดสี + เวลา) ชี้ค้างหรือคลิกแล้วขยายเป็นการ์ดที่มีปุ่มกับ Expected finish ครบ ลากได้โดยไม่ขยาย ขยายไปทางที่มีที่ว่างตอนชิดขอบ เริ่มที่กลางบนและจำตำแหน่งไว้ มี light/dark และ Appearance System/Light/Dark ใน Settings ส่วน Settings กับ Statistics ใช้กล่องมุมโค้งแบบ System Settings (prototype อยู่ที่ branch `prototype/floating-window-look`)
- [spec จะสั่ง agent ให้จัดโครงสร้างโค้ดและทดสอบยังไง](issues/12-code-structure-and-testing.md) — Core (กติกาล้วน รับ `now` จากข้างนอก) + App + CoreTests ใช้ `/tdd` และ Swift Testing ชื่อ test แบบ Given/When/Then มี seam ที่กำหนดไว้ 4 จุด, checklist ทดสอบด้วยมือแบบ Given/When/Then ใน `docs/manual-test.md`, build เป็น 5 milestone ที่ผู้ใช้ต้องบอกผ่านก่อนไปต่อ, เงื่อนไข "เสร็จ" 7 ข้อ และรายงานเป็นภาษาไทย

## Not yet specified

(ตอนนี้ยังไม่มี fog ที่เหลือ เรื่องการแจกจ่ายกับชื่อแอพ/ไอคอนยกขึ้นเป็นตั๋วแล้ว)

## Out of scope

- iOS / iPadOS (ทำแค่ macOS อย่างเดียว ขั้นตอนการ charting)
- Global hotkey
- ตั้งชื่องานให้แต่ละ pomodoro
- เปิดแอพอัตโนมัติตอน login
- Mac App Store / notarization / Apple Developer account แบบเสียเงิน
- หลายภาษา / ภาษาไทยใน UI (v1 ใช้ภาษาอังกฤษอย่างเดียว ตั๋ว "menu bar กับหน้าต่างลอย เกี่ยวกันยังไง")
