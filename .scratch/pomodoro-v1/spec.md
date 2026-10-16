# Pomodot v1 — Spec สำหรับ AI coding agent

> **อ่านก่อนเริ่ม:** spec นี้รวมการตัดสินใจทั้งหมดจาก [map](map.md) และตั๋ว 01–15 ไว้ที่เดียว อ่านจบแล้วต้อง build ได้ครบ 5 milestone **โดยไม่ต้องถามผู้ใช้เรื่องที่ตัดสินไปแล้ว** แต่ละหัวข้อมีลิงก์ไปที่ตั๋วต้นทาง เผื่ออยากรู้ว่าทำไมถึงตัดสินแบบนั้น ถ้า spec ขัดกับตั๋ว **ให้เชื่อ spec** (spec ใช้ข้อที่ตัดสินทีหลังทับข้อเก่าแล้ว)
>
> ผู้ใช้ **ไม่เขียน Swift และไม่ได้อยากเรียน** คุยกับผู้ใช้เป็นภาษาไทย ศัพท์เทคนิคใช้ภาษาอังกฤษได้ ถ้าจำเป็นต้องให้ผู้ใช้ตัดสินอะไร ให้เสนอทางที่แนะนำพร้อม trade-off เป็นภาษาคน ไม่ต้องอธิบาย API

## สารบัญ

- [ส่วน A — กติกากลาง (ใช้ทุก milestone)](#ส่วน-a--กติกากลาง-ใช้ทุก-milestone)
  - [A1. แอพนี้คืออะไร](#a1-แอพนี้คืออะไร)
  - [A2. ศัพท์](#a2-ศัพท์)
  - [A3. เรื่องที่ตัดสินแล้ว ห้ามถามซ้ำ](#a3-เรื่องที่ตัดสินแล้ว-ห้ามถามซ้ำ)
  - [A4. Toolchain และกติกา build](#a4-toolchain-และกติกา-build)
  - [A5. โครงสร้าง repo และ package](#a5-โครงสร้าง-repo-และ-package)
  - [A6. Core กับเวลา](#a6-core-กับเวลา)
  - [A7. การทดสอบ](#a7-การทดสอบ)
  - [A8. เงื่อนไข "เสร็จ" และรายงานส่งงาน](#a8-เงื่อนไข-เสร็จ-และรายงานส่งงาน)
  - [A9. Git, gitflow และการ push](#a9-git-gitflow-และการ-push)
  - [A10. หน้าตา (ใช้ทุกหน้าจอ)](#a10-หน้าตา-ใช้ทุกหน้าจอ)
- [ส่วน B — Milestone](#ส่วน-b--milestone)
  - [M1. โครงแอพ + หน้าต่างลอย](#m1-โครงแอพ--หน้าต่างลอย)
  - [M2. Timer เต็มระบบ](#m2-timer-เต็มระบบ)
  - [M3. แจ้งเตือน + เสียง](#m3-แจ้งเตือน--เสียง)
  - [M4. History + Statistics](#m4-history--statistics)
  - [M5. Settings + Appearance + แจกจ่าย](#m5-settings--appearance--แจกจ่าย)
- [ภาคผนวก](#ภาคผนวก)
  - [P1. ไฟล์ข้อมูล version 1](#p1-ไฟล์ข้อมูล-version-1)
  - [P2. README](#p2-readme)
  - [P3. แหล่งที่มา](#p3-แหล่งที่มา)

---

# ส่วน A — กติกากลาง (ใช้ทุก milestone)

## A1. แอพนี้คืออะไร

**Pomodot** เป็นแอพ Pomodoro timer เล็กๆ บน macOS อยู่บน menu bar (ไม่มี Dock icon) มี **Floating Window** เป็นแคปซูลกระจกเล็กๆ ลอยอยู่บนสุด คลิกแล้วขยายเป็นการ์ดที่มีปุ่มครบ แจกให้เพื่อนเป็น `.zip` ผ่าน GitHub Releases โดยไม่มี Apple Developer account แบบเสียเงิน (ไม่ notarize, ไม่ลง App Store)

ฟีเจอร์ v1:
- ตั้งเวลาได้: Focus / Short Break / Long Break / Pomodoro ต่อ Cycle (ค่าเริ่มต้น 25 / 5 / 15 / 4)
- banner notification + เสียงตอน Phase หมดเวลาเอง
- ไอคอนและเวลานับถอยหลังบน menu bar พร้อมเมนู dropdown ที่ควบคุมได้ครบ
- Floating Window ที่สลับ Always on Top ได้ (ค่าเริ่มต้นคือเปิด)
- auto-start แยก 2 สวิตช์ (Break / Focus)
- Expected finish ของ Phase และของ Cycle
- History + หน้าต่าง Statistics
- Settings + Appearance (System / Light / Dark)
- UI ภาษาอังกฤษอย่างเดียว

**นอก scope ของ v1 (ห้ามทำ):** iOS/iPadOS, global hotkey, ตั้งชื่องานให้แต่ละ Pomodoro, เปิดเองตอน login, App Store/notarization, หลายภาษา, รองรับ downgrade, auto-update (Sparkle หรือแอพเช็กเวอร์ชันเอง), GitHub Actions, ช่วงสถิติแบบอื่น (30 วัน/รายเดือน), streak, ดู/ลบ Pomodoro ทีละอัน, export

## A2. ศัพท์

ไฟล์ [`CONTEXT.md`](../../CONTEXT.md) ที่ root เป็นต้นฉบับ ใช้คำเหล่านี้ทั้งในโค้ด, ชื่อ test, ข้อความ UI และรายงาน

| คำ | ความหมาย | ห้ามใช้ |
|---|---|---|
| **Phase** | การจับเวลาหนึ่งก้อน มี 3 ชนิด: Focus, Short Break, Long Break | session, interval, round |
| **Focus** | Phase สำหรับทำงาน (ค่าเริ่มต้น 25 นาที) | |
| **Short Break** | Phase พักระหว่าง Pomodoro ใน Cycle (ค่าเริ่มต้น 5 นาที) | |
| **Long Break** | Phase พักที่ปิดท้าย Cycle (ค่าเริ่มต้น 15 นาที) | |
| **Pomodoro** | Focus ที่ **เดินจนหมดเวลาเอง** Focus ที่จบแบบอื่น (Skip, Reset, New Cycle) ไม่ใช่ Pomodoro ส่วน Focus ที่ Pause แล้วทำต่อจนครบยังนับ | ใช้เรียก Focus ทุกอัน หรือเรียกคู่ Focus + Break |
| **Cycle** | Pomodoro N อัน (ค่าเริ่มต้น 4) แล้วจบด้วย Long Break 1 ครั้ง แสดงความคืบหน้าแบบ `2/4` | round, set, session |
| **History** | รายการ Pomodoro ทุกอัน (เวลาจบ + ความยาว) เก็บจนกว่าผู้ใช้จะลบ New Cycle กับ Reset ไม่แตะ | log, sessions, stats |
| **Expected finish** | เวลาบนนาฬิกาที่ Phase หรือ Cycle จะจบ ถ้าเดินต่อตั้งแต่ตอนนี้โดยไม่หยุดอีก ของ Cycle คือเวลาจบของ Long Break | ETA, end time |
| **Floating Window** | หน้าต่างเล็กที่ลอยบนแอพอื่น ปกติเป็นแคปซูล คลิกแล้วขยายเป็นการ์ด ปิด = ซ่อน (timer เดินต่อ) | widget, HUD, popover, mini window |
| **Skip** | จบ Phase ปัจจุบันก่อนเวลาแล้วไป Phase ถัดไป Focus ที่โดน Skip ไม่ใช่ Pomodoro | |
| **Reset** | ให้ Phase ปัจจุบันกลับไปเต็มเวลาแล้วหยุดรอ ไม่แตะ Cycle | ใช้เรียกการเริ่ม Cycle ใหม่ |
| **New Cycle** | ทิ้งความคืบหน้าของ Cycle ปัจจุบัน กลับไป Focus แรก แล้วหยุดรอ | reset, restart |

คำที่ spec นี้ใช้เพิ่ม (ใช้ในโค้ดได้):
- **สถานะของ Phase** มี 3 แบบ: **Ready** (เต็มเวลาหรือค้างไว้ ยังไม่เคยเดิน รอให้กด Start, UI แสดง `READY`), **Running** (กำลังเดิน), **Paused** (เคยเดินแล้วหยุดไว้, UI แสดง `PAUSED`)
- **เคย Start แล้ว** = Phase นี้เคยเป็น Running มาแล้วอย่างน้อยครั้งหนึ่ง (ทั้งกด Start เองหรือ auto-start)

## A3. เรื่องที่ตัดสินแล้ว ห้ามถามซ้ำ

| เรื่อง | ค่าที่ตัดสินแล้ว | ตั๋ว |
|---|---|---|
| ชื่อแอพ | **Pomodot** (`Pomodot.app`, เมนู `Quit Pomodot`, `About Pomodot`) | [14](issues/14-app-name-and-icon.md) |
| Bundle identifier | **`com.teppasit.pomodot`** ตั้งแล้ว**ห้ามเปลี่ยน** (สิทธิ์ notification และโฟลเดอร์ข้อมูลผูกกับค่านี้) | [14](issues/14-app-name-and-icon.md) |
| Toolchain | Command Line Tools อย่างเดียว + SwiftPM **ไม่ติดตั้ง Xcode** (ดิสก์ไม่พอ) Swift 6.4, macOS SDK 27.0 | [04](issues/04-xcode-or-clt.md), [11](issues/11-reinstall-clt-verify.md) |
| macOS ขั้นต่ำ | **14 (Sonoma)** | [05](issues/05-minimum-macos.md) |
| สถาปัตยกรรม | Universal (arm64 + x86_64) build ในคำสั่งเดียว | [11](issues/11-reinstall-clt-verify.md) |
| UI framework | SwiftUI + `MenuBarExtra` (แบบเมนู) + AppKit `NSPanel` สำหรับ Floating Window | [03](issues/03-floating-window-apis.md) |
| Dock icon | ไม่มี (`LSUIElement`) | [07](issues/07-menubar-vs-floating.md) |
| ภาษา UI | อังกฤษอย่างเดียว | [07](issues/07-menubar-vs-floating.md) |
| เก็บข้อมูล | JSON 3 ไฟล์ใน `~/Library/Application Support/com.teppasit.pomodot/` | [13](issues/13-data-storage.md) |
| Test | Swift Testing, ชื่อ test แบบ Given/When/Then, ใช้ `/tdd` กับ Core | [12](issues/12-code-structure-and-testing.md) |
| แจกจ่าย | ad-hoc sign ทั้ง bundle, `.zip` ด้วย `ditto`, GitHub Release ที่ `inwpasit619/pomodot` อัปโหลดจากเครื่อง dev ด้วย `gh` | [02](issues/02-run-unsigned-app-gatekeeper.md), [15](issues/15-versioning-and-release.md) |
| เวอร์ชันแรก | `0.9.0` เก็บในไฟล์ `VERSION` | [15](issues/15-versioning-and-release.md) |
| Git | gitflow ไม่มี Pull Request, commit ผ่าน `/commit-fast` เท่านั้น | [15](issues/15-versioning-and-release.md), [`CLAUDE.md`](../../CLAUDE.md) |

## A4. Toolchain และกติกา build

ที่มา: [01](issues/01-build-app-without-xcode.md), [04](issues/04-xcode-or-clt.md), [05](issues/05-minimum-macos.md), [11](issues/11-reinstall-clt-verify.md) และผล research บน branch `research/build-app-without-xcode` (สรุปไว้ที่นี่แล้ว ไม่ต้องไปเปิด)

**เครื่อง dev:** macOS 27.0.1 Apple silicon, CLT ติดตั้งใหม่แล้ว `xcode-select -p` = `/Library/Developer/CommandLineTools`, Apple Swift 6.4 (swiftlang-6.4.0.34.1), SDK 27.0 **ดิสก์ว่างเหลือน้อย (~7GB)** ห้ามติดตั้งอะไรใหญ่ๆ และอย่าสร้าง build cache ซ้ำซ้อนโดยไม่จำเป็น ไม่มี Rosetta (รัน slice x86_64 บนเครื่องนี้ไม่ได้ แต่ build ได้)

### ต้องทำ
1. `Package.swift` ใช้ `platforms: [.macOS(.v14)]`
2. build release แบบ universal ในคำสั่งเดียว: `swift build -c release --arch arm64 --arch x86_64` **ไม่ต้องใช้ `lipo` รวมเอง** (ข้อจำกัดเก่าในตั๋ว 01 ใช้ไม่ได้แล้ว)
3. Swift 6.4 ใช้ build system ใหม่ ไฟล์ออกมาที่ `.build/out/Products/<Debug|Release>/` และ build หลาย arch เขียนทับที่เดียวกัน **script ต้องหา path ด้วย `swift build -c release --arch arm64 --arch x86_64 --show-bin-path` ห้ามเขียน path ตายตัว**
4. ประกอบ `.app` เองด้วย script:
   ```
   Pomodot.app/
     Contents/
       Info.plist
       MacOS/Pomodot              ← executable จาก swift build
       Resources/Pomodot.icns     ← จาก scripts/make-icon.sh
   ```
5. **`Info.plist`** ต้องมีครบ:

   | key | ค่า |
   |---|---|
   | `CFBundleIdentifier` | `com.teppasit.pomodot` |
   | `CFBundleName` | `Pomodot` |
   | `CFBundleDisplayName` | `Pomodot` |
   | `CFBundleExecutable` | `Pomodot` |
   | `CFBundlePackageType` | `APPL` |
   | `CFBundleInfoDictionaryVersion` | `6.0` |
   | `CFBundleShortVersionString` | ค่าในไฟล์ `VERSION` (script ใส่ให้ **ห้ามแก้เลขเองใน plist**) |
   | `CFBundleVersion` | `git rev-list --count HEAD` (script ใส่ให้) |
   | `CFBundleIconFile` | `Pomodot` |
   | `LSMinimumSystemVersion` | `14.0` |
   | `LSUIElement` | `true` |

6. **ad-hoc sign ทั้ง bundle:** `codesign --force --sign - Pomodot.app` (sign ที่ตัว `.app` ห้ามใส่ `--deep` ตอน sign) แล้วตรวจด้วย `codesign --verify --strict --deep Pomodot.app` ต้องผ่าน ถ้า sign แค่ executable จะ verify ไม่ผ่าน, ขอสิทธิ์ notification ไม่ได้ และเครื่องเพื่อนจะขึ้นว่า "damaged" โดยไม่มีปุ่ม Open Anyway
7. ทดสอบ notification ต้องเปิดแอพด้วย `open Pomodot.app` เหมือนผู้ใช้ดับเบิลคลิก ห้ามรันไฟล์ใน `Contents/MacOS` ตรงๆ (executable ที่อยู่นอก `.app` จะ crash ทันทีที่เรียก `UNUserNotificationCenter`)

### ห้ามทำ
- ห้ามใช้ `resources:` ของ SwiftPM / `Bundle.module` (ใน `.app` ที่ประกอบเองจะไปหา path บนเครื่อง dev และทำให้ sign ไม่ผ่าน) ไฟล์ทุกอย่างให้ script copy ไปไว้ที่ `Contents/Resources` แล้วโหลดด้วย `Bundle.main`
- ห้ามใช้ `#Preview` (compile ไม่ผ่านถ้าไม่มี Xcode)
- ห้ามใช้ `.xcassets` / asset catalog (ไม่มี `actool` SwiftPM จะ copy ไปเฉยๆ โดยไม่เตือน)
- ห้ามใช้ XCTest (CLT ไม่มี) ใช้ Swift Testing (`import Testing`)
- ห้ามใช้ `activate(ignoringOtherApps:)` (deprecate ใน 27.0) ใช้ `NSApp.activate()`
- ห้ามใช้ API ที่ต้องใช้ macOS 15 ขึ้นไป ถ้าจำเป็นจริงๆ ต้องครอบด้วย `if #available` และมีทางสำรองบน 14 (รวมถึง API กระจกแบบใหม่ของ macOS 26 ห้ามใช้เป็นทางหลัก)
- ห้ามลง library หรือ dependency ภายนอกใดๆ (Swift Charts, Observation มากับ SDK อยู่แล้ว)
- ห้ามใช้ `ObservableObject` ใช้ `@Observable` ได้เลยเพราะขั้นต่ำคือ 14

### warning ที่รู้แล้วว่าไม่ต้องสนใจ (มีแค่ 2 ตัวนี้)
- `ld: warning: search path '.../Developer/usr/lib' not found`
- `The x86_64 architecture is deprecated for your deployment target (macOS 27.0)` (binary ที่ได้จริงยังเป็น `minos 14.0`)

warning อื่นทุกตัวต้องแก้ แก้ไม่ได้ต้องอธิบายเป็นภาษาคนในรายงาน

### ไอคอนแอพ
- ต้นฉบับคือ [`assets/app-icon.svg`](assets/app-icon.svg) (ภาพที่ render แล้ว: [`assets/app-icon-1024.png`](assets/app-icon-1024.png)) ให้ copy ไปไว้ที่ `Packaging/AppIcon.svg`
- `scripts/make-icon.sh`: `sips` render SVG เป็น PNG 1024 → สร้าง `Pomodot.iconset` ทุกขนาด (16, 32, 128, 256, 512 ทั้ง @1x และ @2x) ด้วย `sips -z` → `iconutil -c icns` → `Pomodot.icns` (ทดสอบบนเครื่อง dev แล้วว่าใช้ได้ทุกขั้น)
- กติกาของ SVG: ผืน 1024×1024 ตัวไอคอน 824×824 วางที่ (100,100) มุมโค้ง rx ≈ 185 **ห้ามใช้ SVG filter** (`feDropShadow`, blur ฯลฯ) เพราะ `sips` ไม่วาด ใช้ linear/radial gradient ได้ ถ้าอยากได้เงาให้วาดเป็นรูปทรงโปร่งแสง
- มีไอคอนแบบเดียว ไม่ทำแบบ Dark / Tinted / Clear

## A5. โครงสร้าง repo และ package

ที่มา: [12](issues/12-code-structure-and-testing.md), [14](issues/14-app-name-and-icon.md), [15](issues/15-versioning-and-release.md)

```
pomodoro-time/                   (repo นี้ remote คือ github.com/inwpasit619/pomodot)
├── Package.swift
├── VERSION                      บรรทัดเดียว เช่น 0.9.0
├── README.md                    (milestone 5, ดูภาคผนวก P2)
├── CONTEXT.md                   ศัพท์ (มีอยู่แล้ว)
├── CLAUDE.md                    กติกาของ repo (มีอยู่แล้ว)
├── Sources/
│   ├── Core/                    กติกาล้วน (library)
│   └── Pomodot/                 แอพ (executable)
├── Tests/
│   └── CoreTests/
│       └── Fixtures/            ไฟล์ตัวอย่าง version 1 จากภาคผนวก P1
├── Packaging/
│   ├── Info.plist               template ที่มีช่องให้ script ใส่ version/build
│   └── AppIcon.svg
├── scripts/
│   ├── make-icon.sh
│   ├── build-app.sh             build → ประกอบ .app → sign → verify (คำสั่งเดียว)
│   └── release.sh               (milestone 5)
├── docs/
│   └── manual-test.md           checklist ทดสอบด้วยมือ
└── .scratch/pomodoro-v1/        map, ตั๋ว, spec นี้ (push ขึ้น repo ด้วย)
```

`.gitignore` ต้องมี `.build/` และโฟลเดอร์ผลลัพธ์ของ script (เช่น `dist/`)

### 3 target

| target | ชนิด | มีอะไร | กติกา |
|---|---|---|---|
| **Core** | library | กติกาทั้งหมด: timer, ตัวนับ Cycle, Skip/Reset/New Cycle, auto-start, Expected finish, กติกาถามยืนยัน, เลือกข้อความ banner, แบ่ง History เป็นวัน/สัปดาห์, ตำแหน่งและท่าทางของ Floating Window, แปลงข้อมูล ↔ JSON | **ห้าม import AppKit / SwiftUI / UserNotifications** (Foundation ได้) ห้ามเรียกเวลาปัจจุบันเอง ห้ามมี timer |
| **Pomodot** | executable | menu bar, Floating Window, Settings, Statistics, เสียง, notification, อ่าน/เขียนดิสก์ | แค่ส่งเหตุการณ์ (ปุ่มที่กด, เครื่อง sleep, tick) ไปให้ Core แล้ววาดผล **ไม่มีกติกาของตัวเอง** |
| **CoreTests** | test | test ของ Core | Swift Testing |

ชื่อ product และ executable target ต้องเป็น `Pomodot` ตรงกับ `CFBundleExecutable` (ไม่ใช้ชื่อ `App` หรือ `PomodotApp`)

## A6. Core กับเวลา

ที่มา: [06](issues/06-timer-rules.md), [12](issues/12-code-structure-and-testing.md)

- **Core ไม่ดูนาฬิกาเอง** ทุกคำสั่งหรือคำถามที่ขึ้นกับเวลาต้องรับ `now: Date` จากผู้เรียก (และรับ `Calendar`/`TimeZone` จากผู้เรียกสำหรับเรื่องวัน/สัปดาห์)
- ตอน Running Core จำแค่ **"เริ่มเดินตอนไหน" + "ตอนนั้นเหลือกี่วินาที"** เวลาที่เหลือ = ค่าที่จำไว้ − (now − ตอนเริ่ม) **ห้ามนับลดทีละวินาที**
- App มี timer ราว 1 วินาทีไว้ส่ง `tick(now)` ให้ Core เพื่อวาดตัวเลขใหม่และให้ Core เช็กว่า Phase หมดหรือยัง
- **Phase หมดเวลาให้ใช้เวลาจบตามกำหนด** (ตอนเริ่ม + เวลาที่เหลือ) ไม่ใช่เวลาของ tick ที่มาเจอ ทั้งเวลาจบของ Pomodoro ใน History และเวลาเริ่มของ Phase ถัดไปที่ auto-start ต่อ จึงไม่มีเวลาคลาดสะสม เวลาจบที่บันทึกลง History ให้ปัดเป็นวินาทีเต็ม
- **tick ที่มาช้า** (เช่น ระบบหน่วงแอพไว้): Core ต้องไล่ทุก Phase ที่จบไปแล้วจนถึง `now` ตามลำดับ (ถ้ามี auto-start ต่อกัน) บันทึก Pomodoro ทุกอันที่เกิดขึ้น ส่วน App แจ้งเตือน + เล่นเสียงแค่ของ Phase ล่าสุดที่จบ ระหว่างที่ timer Running ให้ App ขอ `ProcessInfo.beginActivity(options: .userInitiatedAllowingIdleSystemSleep, …)` เพื่อให้ tick ตรงเวลา (ยังให้เครื่อง sleep ได้ตามปกติ)
- เครื่องจะ sleep → App ส่ง "sleep ณ now" ให้ Core (Core ทำเหมือน Pause) ล็อกจอ / จอดับ / screensaver → App **ไม่ส่งอะไร** timer เดินต่อ

## A7. การทดสอบ

ที่มา: [12](issues/12-code-structure-and-testing.md), [13](issues/13-data-storage.md)

### Unit test (Core)
- ใช้ skill **`/tdd`** กับ Core: red → green ทีละ test, vertical slice, test ผ่าน interface สาธารณะเท่านั้น
- **Swift Testing** ชื่อ test (display name) เป็นประโยค **Given / When / Then** ภาษาอังกฤษ ใช้คำจาก A2 ในตัว test มีคอมเมนต์ `// Given` `// When` `// Then` แบ่งส่วน ตัวอย่าง:
  ```swift
  @Test("Given a Focus at 2/4, when it is skipped, then it moves to Short Break and the count stays 2/4")
  ```
- ไม่ใช้ Cucumber / ไฟล์ `.feature`
- **ค่าที่คาดหวังต้องมาจากตัวอย่างใน spec นี้** (ตัวเลข, ข้อความ, JSON) ห้ามคำนวณซ้ำด้วยสูตรเดียวกับโค้ด
- มี **5 seam** ที่ test ผ่าน (กำหนดไว้แล้ว ไม่ต้องถามผู้ใช้):

| # | seam | เข้า | ออก | milestone |
|---|---|---|---|---|
| 1 | **Timer** | เหตุการณ์ (Start/Pause/Resume, Skip, Reset, New Cycle, sleep, tick, เปิดแอพใหม่, เปลี่ยน Settings) + `now` | Phase, ตัวนับ, สถานะ, เวลาที่เหลือ, Expected finish, Pomodoro ที่เกิดขึ้น, ต้องถามยืนยันไหม | M2 |
| 2 | **History / Statistics** | รายการ Pomodoro + `now` + ปฏิทินเครื่อง | Today / This Week / All Time / กราฟ 7 วัน | M4 |
| 3 | **ข้อความแจ้งเตือน** | Phase ที่จบ + วิธีที่จบ + สวิตช์ auto-start | แจ้งเตือนไหม + หัวข้อ + เนื้อความ | M3 |
| 4 | **ตำแหน่งและท่าทางของ Floating Window** | ตำแหน่งแคปซูล + พื้นที่จอ / เหตุการณ์ของเมาส์ + เวลา | ทิศที่การ์ดขยาย, ตำแหน่งที่ใช้ได้, ขยายหรือหุบ | M2 (ตำแหน่งเริ่มต้นตั้งแต่ M1) |
| 5 | **ข้อมูลที่บันทึกไว้** | ข้อความในไฟล์ (หรือ "ไม่มีไฟล์") | Settings / สถานะ timer / History หรือ "อ่านไม่ออก ใช้ค่าเริ่มต้น" และทำย้อนกลับได้ | M2 (state), M4 (history), M5 (settings) |

รายการ test ของแต่ละ seam อยู่ในหัวข้อของ milestone นั้น

### Checklist ทดสอบด้วยมือ (`docs/manual-test.md`)
- แบ่งหมวด: **Floating Window / Menu bar / Notification & Sound / Statistics / Appearance / ติดตั้งบนเครื่องเพื่อน** (เพิ่มหมวด "ข้อมูลที่บันทึกไว้" ได้)
- แต่ละข้อเป็น `- [ ]` เขียนแบบ **Given / When / Then** ภาษาไทยที่คนไม่เขียนโค้ดทำตามได้ ติดป้าย milestone (เช่น `(M2)`) **ห้ามมีคำสั่ง terminal**
- เพิ่มรายการทีละ milestone ตามที่ระบุในหัวข้อของ milestone นั้น
- **agent ทำเองก่อนในข้อที่ทำได้** (build, ประกอบ `.app`, เปิดแอพ, ถ่าย screenshot) แล้วส่งให้ผู้ใช้เฉพาะข้อที่ต้องใช้คน (ฟังเสียง, กด Allow, ลาก, เสียบ/ถอดจอ, เครื่องเพื่อน)

## A8. เงื่อนไข "เสร็จ" และรายงานส่งงาน

ที่มา: [12](issues/12-code-structure-and-testing.md)

**ทุก milestone** ต้องผ่านครบ 7 ข้อ ไม่ผ่านแม้แต่ข้อเดียว = ห้ามบอกว่าเสร็จ
1. `swift test` ผ่านทุกข้อ
2. `swift build -c release --arch arm64 --arch x86_64` ผ่าน
3. ไม่มี warning นอกจาก 2 ตัวที่รู้แล้ว (A4) ถ้ามีตัวใหม่ต้องแก้ แก้ไม่ได้ต้องอธิบายเป็นภาษาคนในรายงาน
4. Core ไม่ import AppKit / SwiftUI / UserNotifications (script ตรวจอัตโนมัติด้วย `grep`)
5. `scripts/build-app.sh` คำสั่งเดียว build → ประกอบ `.app` → ad-hoc sign ทั้ง bundle → `codesign --verify --strict --deep` ผ่าน (หา path ด้วย `--show-bin-path`)
6. agent เปิดแอพจริงด้วย `open` แล้วแนบ screenshot
7. รายงานส่งงานเป็น**ภาษาไทย** มี 3 ส่วน:
   - รายชื่อ test Given/When/Then ที่เพิ่มใน milestone นี้
   - checklist ทดสอบด้วยมือที่เหลือให้ผู้ใช้ทำ
   - สิ่งที่ยังไม่ได้ทำ หรือทำต่างจาก spec พร้อมเหตุผล

จบแต่ละ milestone ต้องได้แอพที่เปิดใช้ได้ **ผู้ใช้ต้องบอก "ผ่าน" ก่อนเริ่ม milestone ถัดไป** ระหว่างที่ยังไม่มีหน้า Settings (ก่อน M5) ให้ใช้ค่าเริ่มต้น

## A9. Git, gitflow และการ push

ที่มา: [15](issues/15-versioning-and-release.md), [`CLAUDE.md`](../../CLAUDE.md)

- **commit ผ่าน skill `/commit-fast` เท่านั้น ห้ามรัน `git commit` เอง** (`git add` ได้)
- branch:

| branch | ใช้ทำอะไร |
|---|---|
| `main` | มีแค่โค้ดที่ออก release แล้ว merge เข้า `main` ทุกครั้งต้องมี tag `vX.Y.Z` (ตอนนี้มีแต่เอกสารวางแผน) |
| `develop` | รวมงานที่ผ่านแล้ว แยกจาก `main` ตอนเริ่ม M1 |
| `feature/m1-floating-window`, `feature/m2-timer`, `feature/m3-notifications`, `feature/m4-statistics`, `feature/m5-settings-release` | milestone ละ branch แยกจาก `develop` ผู้ใช้บอก "ผ่าน" แล้วค่อย merge กลับเข้า `develop` |
| `release/X.Y.Z` | แยกจาก `develop` ใช้แก้ `VERSION`, ร่าง release notes, ตรวจรอบสุดท้าย แล้ว merge เข้า `main` + tag และ merge กลับเข้า `develop` |
| `hotfix/X.Y.Z` | แก้บั๊กของเวอร์ชันที่ออกแล้ว แยกจาก `main` merge เข้าทั้ง `main` (+ tag) และ `develop` |

- merge ในเครื่องด้วย `git merge --no-ff` **ไม่เปิด Pull Request** การที่ผู้ใช้บอก "ผ่าน" ถือเป็นการรีวิว
- ใช้คำสั่ง git ธรรมดา ไม่ติดตั้งเครื่องมือ `git-flow`
- remote ชื่อ `origin` = `https://github.com/inwpasit619/pomodot` (repo public ตอนนี้ยังว่าง)
- **push ตั้งแต่ M1** (`main`, `develop` และ feature branch ที่ทำอยู่) เพื่อ backup ส่วนหน้า Releases ว่างจนกว่าจะออก `0.9.0`
- **ก่อน push ครั้งแรกต้องหยุด:** ตอนนี้ `gh` ล็อกอินเป็น `teppasit-lovecode` ซึ่งมีสิทธิ์แค่ READ ใน repo นี้ และ token ของ `inwpasit619` หมดอายุแล้ว ให้ผู้ใช้รัน `! gh auth login` (เลือกบัญชี `inwpasit619`) แล้วตรวจว่า `gh repo view inwpasit619/pomodot --json viewerPermission` ได้ `ADMIN` หรือ `WRITE` **ห้ามหาทางอ้อมเอง**
- push `.scratch/` (map + ตั๋ว + spec) และ `CLAUDE.md` ขึ้นไปด้วย
- branch `research/*` และ `prototype/*` **ห้าม push** (อยู่ในเครื่องอย่างเดียว เนื้อหาที่ต้องใช้สรุปไว้ใน spec นี้แล้ว)

## A10. หน้าตา (ใช้ทุกหน้าจอ)

ที่มา: [10](issues/10-floating-window-look.md) (prototype ที่ผู้ใช้เลือกคือแบบ **G** อยู่ที่ branch `prototype/floating-window-look` ไฟล์ `.scratch/pomodoro-v1/prototypes/floating-window-prototype.html` เปิดดูในเครื่องได้ด้วย `git show prototype/floating-window-look:.scratch/pomodoro-v1/prototypes/floating-window-prototype.html > /tmp/proto.html`)

"Modern" ของแอพนี้แปลว่า:
- พื้น**กระจกโปร่งแสงเบลอ** (material ของ macOS เช่น `NSVisualEffectView` หรือ SwiftUI `Material` ซึ่งใช้ได้บน 14)
- มุมโค้งมน
- ตัวเลขใหญ่แบบ **SF Rounded** ที่ความกว้างตัวเลขเท่ากันทุกตัว (`.monospacedDigit()`) ตัวเลขไม่ขยับตอนนับ
- animation นุ่มๆ
- **สีประจำ Phase:** Focus = แดงมะเขือเทศ `#F0524F`, Short Break = เขียว `#2FBF5B`, Long Break = น้ำเงิน `#0A84FF` ใช้กับจุด, ป้าย, แถบ และปุ่มหลัก
- ฟอนต์ระบบ (SF) ทั้งแอพ ไม่ลงฟอนต์เพิ่ม
- **Light / Dark:** ทุกหน้าต่างเปลี่ยนตาม Appearance รวมถึงแคปซูล Light = กระจกขาว ตัวอักษรเข้ม, Dark = กระจกเทาเข้ม ตัวอักษรขาว (ค่าใน prototype ไว้อ้างอิง: light material `rgba(248,248,250,.62)` ตัวอักษร `#1d1d1f`, dark material `rgba(38,38,42,.55)` ตัวอักษร `#f5f5f7`)
- **Reduce motion** ใน Accessibility เปิดอยู่ → ไม่เด้ง และขยาย/หุบโดยไม่มี animation
- Settings กับ Statistics: เนื้อหาจัดเป็น**กล่องมุมโค้งแบบ System Settings**, หัวข้อแต่ละส่วนเป็นตัวเล็กสีเทา, สวิตช์และปุ่มสำคัญเป็น**สีแดงมะเขือเทศ**, ตัวเลขสถิติใช้ SF Rounded
- ไอคอนในแอพใช้ **SF Symbols** ไม่ใช้ emoji แทนไอคอน (ข้อความที่ผู้ใช้เลือกให้มี 🍅 เช่น `Today: 🍅 5` ใช้ตามที่ระบุ)

---

# ส่วน B — Milestone

## M1. โครงแอพ + หน้าต่างลอย

branch: `feature/m1-floating-window` (สร้าง `develop` จาก `main` ก่อน) **ทำเรื่องที่เสี่ยงที่สุดก่อน** คือหน้าต่างลอยที่ทับ fullscreen / ไม่แย่ง focus / อยู่ทุก Space

### ขอบเขต
- `Package.swift` 3 target (A5), `VERSION` = `0.9.0`, `Packaging/Info.plist`, `.gitignore`
- `scripts/make-icon.sh` และ `scripts/build-app.sh` ผ่านเงื่อนไข "เสร็จ" ข้อ 4–5
- แอพ SwiftUI ที่มี `@NSApplicationDelegateAdaptor`, `LSUIElement` (ไม่มี Dock icon, ไม่อยู่ใน Cmd-Tab, ไม่มีเมนูแอพด้านบนจอ)
- `MenuBarExtra` แบบ `.menu` แสดงไอคอน `timer` (ยังไม่มีเวลา) มีเมนูอย่างน้อย `Hide/Show Floating Window`, `Always on Top`, `Quit Pomodot`
- Floating Window ตอนย่อ (แคปซูล ~128×38 pt แสดงจุดสีของ Focus + `25:00` + `READY`) ลอยตามกติกาข้างล่าง วางที่ตำแหน่งเริ่มต้น
- ตอนเริ่ม App ต้องเช็กว่า SF Symbols `timer`, `cup.and.saucer.fill`, `pause.circle` โหลดได้จริง (`NSImage(systemSymbolName:accessibilityDescription:)` ต้องไม่ได้ `nil`) ถ้าตัวไหนได้ `nil` ให้หยุดแล้วรายงาน **ห้ามเปลี่ยนไปใช้ตัวอื่นเอง**
- push ครั้งแรก (หยุดให้ผู้ใช้ `gh auth login` ก่อน ตาม A9)

### Floating Window = `NSPanel` ที่ห่อ SwiftUI view
ที่มา: [03](issues/03-floating-window-apis.md) และ research บน branch `research/floating-window-apis`

SwiftUI ล้วนทำไม่ได้ (ต้อง macOS 15, กันแย่ง focus ไม่ได้, SwiftUI reset `collectionBehavior` ทิ้งทำให้ทับ fullscreen ไม่ได้) จึงใช้ `NSPanel` ที่แอพเป็นเจ้าของเอง โครงที่ research ทดลองแล้ว:

```swift
final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }   // borderless panel กดปุ่มไม่ได้ถ้าไม่ override
}

let panel = FloatingPanel(contentRect: …,
                          styleMask: [.borderless, .nonactivatingPanel],
                          backing: .buffered, defer: false)
panel.level = .floating                         // Always on Top ปิด → .normal
panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .canJoinAllApplications]
panel.hidesOnDeactivate = false                 // ค่าเริ่มต้นของ NSPanel คือ true จะหายตอนแอพไม่ active
panel.backgroundColor = .clear
panel.isOpaque = false
panel.contentView = NSHostingView(rootView: FloatingView(model: model))
panel.orderFrontRegardless()                    // แสดงโดยไม่ activate แอพ
```

กับดักที่ต้องรู้:
1. **root view ของ SwiftUI ต้องมี `.frame(width:height:)` ตายตัว** ตามสถานะ (แคปซูล/การ์ด) ถ้าปล่อยให้ขนาดตามเนื้อหา Auto Layout จะ crash (`NSGenericException`) ตอนข้อความเปลี่ยน
2. **state ของ timer ต้องอยู่ระดับแอพ** (model `@Observable` ตัวเดียวที่ทั้ง menu bar และ panel ใช้ร่วมกัน) ห้ามอยู่ใน view ของ Floating Window เพราะผู้ใช้ซ่อนหน้าต่างได้
3. สลับ Always on Top = `panel.level = onTop ? .floating : .normal` มีผลทันที
4. `.canJoinAllApplications` (macOS 13+) Apple แนะนำสำหรับ floating window/overlay ที่ต้องขึ้นใน fullscreen space ของแอพอื่น research ยังไม่ได้ทดสอบด้วยการคลิกจริง ให้ยืนยันด้วย checklist ข้อ fullscreen
5. ใช้ `isMovableByWindowBackground` ไม่ได้กับกติกาลากใน M2 (ลากแล้วต้องไม่ขยาย, คลิกแล้วขยาย) ให้จัดการเมาส์เอง (ทำใน M2 ได้ ส่วน M1 ใช้แบบง่ายไปก่อนได้)
6. การชี้ (hover) ต้องทำงานแม้แอพไม่ active (tracking area แบบ active always)

### Always on Top
- สวิตช์อยู่ในเมนู menu bar **ที่เดียว** (ไม่อยู่ใน Settings, ไม่มีปุ่มหมุดบน Floating Window) ค่าเริ่มต้นคือ**เปิด** แอพจำค่าไว้ (เก็บใน `state.json` ตั้งแต่ M2)

### ตำแหน่งเริ่มต้น
- เปิดแอพครั้งแรก: **กลางด้านบน ใต้ menu bar** ของจอหลัก (ห่างจากใต้ menu bar ~12 pt) ไม่ใช่มุมขวาบนเพราะ banner แจ้งเตือนจะทับ
- เปิดแอพครั้งแรกสุด Floating Window **แสดงเสมอ**

### Test (Core) M1
- seam 4: Given จอหลักมีพื้นที่ใช้งาน (0, 0)–(1440, 875) (พิกัด AppKit แกน y ชี้ขึ้น), When ไม่มีตำแหน่งที่จำไว้, Then จุดกึ่งกลางแคปซูลอยู่ที่ x = 720 และขอบบนของแคปซูลอยู่ที่ y = 863 (875 − 12)

### Checklist ทดสอบด้วยมือ M1
- Finder › Applications (หรือโฟลเดอร์ที่ build) เห็นไอคอนแอพแบบ A (แคปซูลขาวบนพื้นแดง) ชื่อ `Pomodot` **ผู้ใช้บอกผ่านเรื่องหน้าตาของไอคอน** (ไอคอนจริงต่างจากหน้าตัวอย่างนิดหน่อย เงาเป็นรูปทรงธรรมดา ไม่เบลอ)
- เปิดแอพแล้วไม่มีไอคอนใน Dock และไม่อยู่ใน Cmd-Tab
- ไอคอน `timer` ขึ้นบน menu bar คลิกแล้วได้เมนู dropdown
- เปิดแอพครั้งแรก แคปซูลอยู่กลางด้านบนใต้ menu bar
- เปิด Safari (หรือแอพอื่น) แบบ fullscreen → แคปซูลยังลอยอยู่บนสุด และกระจกโปร่งแสงยังอ่านตัวเลขได้
- พิมพ์อยู่ในแอพอื่นแล้วคลิกแคปซูล → แอพที่พิมพ์อยู่ยังเป็นแอพที่ active (ไม่แย่ง focus)
- สลับ Space (Mission Control) → แคปซูลตามไปทุก Space
- ปิด Always on Top ในเมนู → แคปซูลไปอยู่หลังหน้าต่างอื่นได้ เปิดกลับ → ลอยบนสุดทันที
- Hide Floating Window ในเมนู → แคปซูลหาย, Show → กลับมา

---

## M2. Timer เต็มระบบ

branch: `feature/m2-timer`

### ขอบเขต
Core seam 1 (Timer) + seam 4 (Floating Window) + seam 5 ส่วน `state.json`, การ์ดขยาย/หุบ/ลาก, Expected finish, เมนูควบคุมได้ครบ, ไอคอน menu bar ครบทุกสถานะ, กล่องยืนยัน, auto-pause ตอน sleep, Quit แล้วเปิดใหม่กลับมาที่เดิม (รายการเมนูของฟีเจอร์ที่ยังไม่ได้ทำ เช่น `Statistics…`, `Settings…`, `Today:` ให้ใส่ใน milestone ของมัน)

### กติกาของ timer
ที่มา: [06](issues/06-timer-rules.md)

**ลำดับปกติ**
- เปิดแอพครั้งแรก: Focus 1/N เต็มเวลา **Ready**
- Focus หมดเวลาเอง → เป็น Pomodoro (ตัวนับ +1) → ถ้าครบ N ไป **Long Break** ไม่ครบไป **Short Break**
- Short Break จบ → Focus ถัดไป
- Long Break จบ → Cycle ใหม่ที่ Focus 1/N

**ตัวเลข `k/N`** (กติกาเต็มที่ spec นี้กำหนดจากตั๋ว 06 และ 12)
- Core จำ 2 ค่า: `done` = จำนวน Pomodoro ที่ได้แล้วใน Cycle นี้ และ `k` = เลขที่แสดง
- ตอนเป็น Focus: `k = done + 1` (กำลังทำ Pomodoro ที่ k)
- ตอนเป็น Break: `k` = เลขของ Focus ก่อนหน้า ไม่ว่า Focus นั้นจะครบหรือโดน Skip (Long Break จึงเป็น `N/N` เสมอ)
- Focus ถัดจาก Break: `k = done + 1` (ถ้า Focus ก่อนหน้าโดน Skip จะได้เลขเดิมซ้ำ เพราะยังขาด Pomodoro อันนั้น)
- จุดบอกความคืบหน้าบนการ์ด: จุดทึบ = `done`, ทั้งหมด N จุด
- ตัวอย่าง (N = 4): Focus 1/4 ครบ → Short Break 1/4 → Focus 2/4 โดน Skip → Short Break 2/4 (done ยังเป็น 1) → Focus 2/4 → ครบ → Short Break 2/4 → … → Focus 4/4 ครบ → Long Break 4/4 → Focus 1/4 ของ Cycle ใหม่

**ปุ่ม**
- **Start / Pause / Resume เป็นปุ่มเดียว:** Ready → Start → Running; Running → Pause → Paused (เวลาค้างไว้); Paused → Resume → Running ต่อจากจุดเดิม
- **Skip** (ใช้ได้ทุกสถานะ):

  | Skip ตอนอยู่ใน | ไปที่ | ตัวนับ |
  |---|---|---|
  | Focus | Short Break (เสมอ แม้เป็น Focus N/N) | `done` ไม่ขยับ (ไม่ใช่ Pomodoro) |
  | Short Break | Focus ถัดไป | ไม่ขยับ |
  | Long Break | Focus 1/N ของ Cycle ใหม่ | เริ่มนับใหม่ |

  Phase ถัดไปหลัง Skip เริ่มเองหรือรอ ใช้กติกา auto-start เดียวกับตอนหมดเวลาเอง (รวมถึงหยุดรอเสมอหลัง Long Break) **Skip ไม่มีแจ้งเตือน/เสียง**
- **Reset** (อยู่บน Floating Window และในเมนู) = Phase ปัจจุบันกลับไปเต็มเวลาตาม **Settings ล่าสุด** แล้วเป็น Ready ไม่แตะตัวนับ Cycle Focus ที่ Reset ไม่ใช่ Pomodoro
- **New Cycle** (อยู่ในเมนูเท่านั้น ไม่อยู่บน Floating Window) = กลับไป Focus 1/N (`done` = 0) เป็น Ready กดตอนเดินอยู่ก็ได้ **ไม่ลบ History**

**Auto-start** (สวิตช์อยู่ใน Settings M5 ก่อนหน้านั้นใช้ค่าเริ่มต้น = ปิดทั้งคู่)
- 2 สวิตช์: "Start breaks automatically" กับ "Start Focus automatically" **ค่าเริ่มต้นปิดทั้งคู่**
- เปิดอยู่ → Phase ถัดไปเริ่ม**ทันที** (ไม่มีหน่วง) ปิด → เตรียม Phase ถัดไปเต็มเวลาแล้ว Ready
- **จบ Long Break หยุดรอเสมอ** สวิตช์ Focus มีผลแค่ Short Break → Focus ใน Cycle เดียวกัน

**Sleep / ล็อกจอ**
- ล็อกจอ, จอดับ, screensaver → timer **เดินต่อ**
- เครื่อง sleep จริง (ปิดฝา, สั่ง Sleep) → **auto-pause** ตื่นมายังเป็น Paused ต้องกด Resume เอง (App ฟัง `NSWorkspace.willSleepNotification` เท่านั้น)
- ไม่มีแจ้งเตือน/เสียงตอน auto-pause

**ปิดแอพแล้วเปิดใหม่** (Quit, รีสตาร์ทเครื่อง, Force Quit)
- จำ Phase, ตัวนับ, เวลาที่เหลือ เปิดมาเป็น **Paused** (ถ้าตอนบันทึกเป็น Ready ก็กลับมาเป็น Ready) ช่วงที่ปิดแอพไว้ไม่นับเวลา

**เปลี่ยน Settings ระหว่างที่ timer เดิน**
- เปลี่ยนเวลา Focus / Short Break / Long Break → Phase ที่เคย Start แล้วใช้เวลาเดิมจนจบ Phase ถัดไปของชนิดนั้นใช้ค่าใหม่
- เปลี่ยน Pomodoro ต่อ Cycle → เริ่มใช้ตอนเข้า Cycle ใหม่ (Cycle ปัจจุบันจำ N ของตัวเองไว้)
- **ข้อยกเว้น:** Phase ปัจจุบันที่ยังไม่เคย Start ใช้ค่าเวลาใหม่ทันที และถ้า Cycle ยังไม่มีความคืบหน้าเลย (`done` = 0 และ Phase ปัจจุบันยังไม่เคย Start) จำนวน Pomodoro ต่อ Cycle ก็ใช้ค่าใหม่ทันทีด้วย
- อยากใช้ค่าใหม่ทันทีกลางช่วง → กด Reset

**การแสดงเวลา**
- นับถอยหลังเวลาที่เหลือแบบ `mm:ss` เสมอ เกิน 60 นาทีก็เป็น `90:00` (ไม่มีชั่วโมง)
- **Expected finish** ของ Phase และของ Cycle:
  - = ตอนนี้ + เวลาที่เหลือของ Phase ปัจจุบัน (+ ของ Cycle บวกความยาวของทุก Phase ที่ยังเหลือจนจบ Long Break) สมมติว่าไม่หยุดอีก
  - Phase ที่ยังไม่เริ่มใช้ความยาวตาม Settings ปัจจุบัน จำนวน Focus ที่เหลือใช้ N ของ Cycle ปัจจุบัน
  - ตอน Running ค่านิ่ง ตอน Paused / Ready ค่าเลื่อนไปตามเวลาจริง ("ถ้ากดต่อตอนนี้จะเสร็จกี่โมง")
  - Skip Focus ทำให้ Expected finish ของ Cycle เลื่อนออกไป (ยังขาด Pomodoro อีกอัน)
  - แสดงตามรูปแบบเวลาของเครื่อง (12/24 ชม.) ไม่มีวินาที

**ถามยืนยัน** ([07](issues/07-menubar-vs-floating.md)) ถามเฉพาะตอนมีของจะหายจริง:
- **Reset:** Phase ปัจจุบันเคย Start แล้ว (Running หรือ Paused)
- **New Cycle:** `done` ≥ 1 หรือ Phase ปัจจุบันเคย Start แล้ว
- นอกจากนั้นทำเลยโดยไม่ถาม ไม่มีช่อง "ไม่ต้องถามอีก"
- **กดไม่ได้ (สีจาง) ตอนกดแล้วไม่มีอะไรเปลี่ยน** ทั้งในเมนูและปุ่ม Reset บนการ์ด: Reset ตอน Phase ปัจจุบันยังไม่เคย Start (เต็มเวลาตาม Settings ล่าสุดอยู่แล้ว), New Cycle ตอน Focus 1/N Ready ที่ `done` = 0
- กล่องยืนยันต้อง**ขึ้นมาอยู่ด้านหน้าเสมอ** (แอพที่ไม่มี Dock icon มักทำให้กล่องไปอยู่ข้างหลัง → `NSApp.activate()` ก่อนแสดง)
- ข้อความ (agent ร่าง):
  - Reset: หัวข้อ `Reset this Focus?` (หรือ `Reset this Short Break?` / `Reset this Long Break?`) เนื้อความ `It will go back to 25:00.` (ใช้เวลาจริง) และถ้าเป็น Focus ต่อด้วย ` It won't count as a Pomodoro.` ปุ่ม `Reset` / `Cancel`
  - New Cycle: หัวข้อ `Start a new Cycle?` เนื้อความ `Progress in this Cycle will be cleared. Your History is kept.` ปุ่ม `New Cycle` / `Cancel`

### Floating Window: แบบ G "Island → Card"
ที่มา: [10](issues/10-floating-window-look.md)

```
ย่อ (ปกติ)                ขยาย (คลิก)        
( ● 24:12 )        →     ┌──────────────────────────────┐
                         │ [● Focus] ●○○○ 2/4       [×] │
                         │ 24:12  PAUSED                │
                         │ ━━━━━━━━━━━━━━━━━━━━━━━━──   │
                         │ Phase ends     Cycle ends    │
                         │ 3:17 PM        4:32 PM       │
                         │ [ ▶︎ Resume ]   [↺]   [⏭]    │
                         └──────────────────────────────┘
```

- **ย่อ** (~128×38 pt แคปซูล): จุดสีของ Phase + `mm:ss` เท่านั้น Paused มีคำว่า `PAUSED`, Ready มีคำว่า `READY`, Running จุดเรืองแสงเบาๆ
- **ขยาย** (~284×200 pt การ์ดมุมโค้ง):
  - ป้าย Phase (`Focus` / `Short Break` / `Long Break`) สีของ Phase
  - จุดความคืบหน้า N จุด + `k/N`
  - ปุ่มซ่อน (SF Symbol `xmark`) มุมขวาบน = Hide Floating Window
  - เวลาตัวใหญ่ + `PAUSED` / `READY`
  - แถบเวลาที่เหลือ (เทียบกับความยาวเต็มของ Phase นี้)
  - **Expected finish:** `Phase ends` และ `Cycle ends` (โชว์เฉพาะตอนขยาย ตอนซ่อนหน้าต่างดูได้จากเมนู)
  - ปุ่มใหญ่สีของ Phase: `Start` / `Pause` / `Resume` (SF Symbol `play.fill` / `pause.fill`) + ปุ่ม Reset (`arrow.counterclockwise`) + Skip (`forward.end.fill`)
- ปุ่มบนหน้าต่างมี**แค่** Start/Pause/Resume, Reset, Skip, ซ่อน **ไม่มี** New Cycle, Quit, หมุด, เมนูคลิกขวา
- **ตอน Paused:** ตัวเลขค่อยๆ จางลงแล้วเข้มขึ้นวนไป (เหมือนหายใจ) + `PAUSED`
- **เปลี่ยน Phase:** แคปซูลหรือการ์ด**เด้งเบาๆ ครั้งเดียว** (ขยายนิดเดียวแล้วกลับ ~0.7 วิ) + **สีค่อยๆ เปลี่ยน**เป็นสีของ Phase ใหม่ ไม่กะพริบซ้ำ ไม่ใช่การแจ้งเตือน
- หมด Phase แล้ว Floating Window **ไม่เด้งกลับมาเอง**ถ้าซ่อนอยู่

**ชี้ / คลิก / ลาก**
- **ชี้เฉยๆ ไม่ขยาย** (เปลี่ยนจากชี้ค้าง 0.3 วิ เมื่อ 2026-10-16: แคปซูลอยู่ใต้ menu bar ซึ่งเมาส์ผ่านบ่อย ชี้แล้วขยายเองบังงาน) ตอนชี้ แคปซูลกว้างขึ้นนิดหนึ่ง (~12 pt, สูงขึ้น ~4 pt) ด้วย spring เด้งเบาๆ แบบ Dynamic Island ให้รู้ว่าคลิกได้ เอาเมาส์ออกแล้วกลับขนาดเดิม
- เมาส์ออกแล้วรอ **0.5 วิ** → หุบ (กลับมาก่อน 0.5 วิ ไม่หุบ)
- **คลิกแคปซูล (ไม่ลาก) → ขยายทันที**
- **กดค้างแล้วลากแคปซูลได้โดยไม่ขยาย** ระหว่างลากไม่ขยาย ปล่อยแล้วก็ไม่ขยาย จนกว่าจะคลิก (เมาส์เลื่อนเกิน ~3 pt ระหว่างกด = ลาก)
- ตอนขยายอยู่ ลากการ์ดได้ถ้ากดที่พื้นที่ที่ไม่ใช่ปุ่ม
- ลากได้ถึงขอบพื้นที่ใช้งานของจอ (ไม่ทับ menu bar และ Dock) ลากออกนอกจอไม่ได้
- ขยาย/หุบใช้ animation ~0.35 วิ

**การขยายใกล้ขอบจอ** (แคปซูลอยู่ที่เดิมเสมอ การ์ดขยายไปทางที่มีที่ว่าง)
- "ขอบจอ" = พื้นที่ใช้งานจริง (`visibleFrame`) ของ**จอที่แคปซูลอยู่** ไม่รวม menu bar และ Dock
- แนวตั้ง: ปกติการ์ดอยู่กึ่งกลางแคปซูล (ขยายออกจากตรงกลางทั้งขึ้นและลง) ถ้าจะทะลุขอบบน → ขยาย**ลงล่าง** (ขอบบนการ์ด = ขอบบนแคปซูล) ถ้าจะทะลุขอบล่าง → ขยาย**ขึ้นบน** (ขอบล่างการ์ด = ขอบล่างแคปซูล)
- แนวนอน: ปกติการ์ดอยู่กึ่งกลางแคปซูล ถ้าจะทะลุขอบขวา → ขอบขวาการ์ด = ขอบขวาแคปซูล (ขยายไปทางซ้าย) ถ้าจะทะลุขอบซ้าย → ขอบซ้ายการ์ด = ขอบซ้ายแคปซูล
- เลือกทิศตอนเริ่มขยาย แล้วไม่เปลี่ยนจนกว่าจะหุบ
- **ห้าม**ใช้วิธี "ขยายแล้วเลื่อนการ์ดหนีขอบ" (การ์ดขยับหนีเมาส์ → เมาส์หลุด → หุบ/ขยายวนไม่จบ)

**ตำแหน่งที่จำไว้**
- จำ**จุดกึ่งกลางของแคปซูลตอนย่อ** ในพิกัดรวมทุกจอของ AppKit (ไม่จำตอนขยาย) เก็บใน `state.json`
- ถ้าจุดนี้ไม่อยู่ในพื้นที่ใช้งานของจอไหนเลย (ถอดจอเสริม, เปลี่ยนความละเอียด) → กลับไปตำแหน่งเริ่มต้น (M1)

### Menu bar
ที่มา: [07](issues/07-menubar-vs-floating.md), [14](issues/14-app-name-and-icon.md), [15](issues/15-versioning-and-release.md)

**ไอคอน** = SF Symbols สีเดียวแบบ template image (เปลี่ยนสีตาม menu bar เหมือน Wi‑Fi/แบตเตอรี่) ไม่มีสี ไม่ใช่ emoji ตัวเลขเป็น monospaced digit

| สถานะ | ไอคอน | เวลา |
|---|---|---|
| Focus Running | `timer` | `mm:ss` |
| Short/Long Break Running | `cup.and.saucer.fill` | `mm:ss` |
| Paused (ทุก Phase) | `pause.circle` (ไม่บอกว่า Phase ไหน) | `mm:ss` สีจางลง |
| Ready | ไอคอนของ Phase ที่รอ (`timer` หรือ `cup.and.saucer.fill`) | ไม่มี |

ไม่มีสวิตช์ซ่อนเวลา

**เมนู dropdown** (เมนูธรรมดา ไม่ใช่ popover) — หน้าตาสุดท้ายหลังครบทุก milestone:

```
Today: 🍅 5                          ← (M4) สรุปวันนี้ กดไม่ได้
Focus 2/4 · ends 14:35               ← Phase ปัจจุบัน + Expected finish ของ Phase (กดไม่ได้)
Cycle ends 16:10                     ← Expected finish ของ Cycle (กดไม่ได้)
──────────────
Pause                                ← Start / Pause / Resume ตามสถานะ
Skip
Reset…
New Cycle…
──────────────
Hide Floating Window                 ← Show Floating Window ตอนซ่อนอยู่
✓ Always on Top
──────────────
Statistics…                          ← (M4)
Settings…                            ← (M5)
──────────────
About Pomodot                        ← (M5)
Check for Updates…                   ← (M5)
──────────────
Quit Pomodot
```

- บรรทัดที่ 2 ใช้ชื่อ Phase จริง เช่น `Short Break 2/4 · ends 14:40`, `Long Break 4/4 · ends 15:00` เวลาตามรูปแบบเครื่อง
- `…` ท้าย Reset / New Cycle = อาจมีกล่องถาม (ตามธรรมเนียม Mac) และเป็นสีจางกดไม่ได้ตอนกดแล้วไม่มีอะไรเปลี่ยน (ดู "ถามยืนยัน")
- **ออกจากแอพได้ทางเดียวคือ `Quit Pomodot`**
- ไอคอนบน menu bar อาจถูกซ่อนหลังรอยบาก → **เปิดแอพซ้ำตอนรันอยู่แล้ว** (Finder / Spotlight) = แสดง Floating Window ไม่เปิดตัวที่สอง (`applicationShouldHandleReopen` ถ้าใช้ไม่ได้กับแอพแบบ `LSUIElement` ให้หาทางอื่นแล้วบอกในรายงาน)
- จำว่า Floating Window ซ่อนหรือแสดงอยู่ข้ามการเปิดแอพใหม่

### ข้อมูล: `state.json` (seam 5)
ที่มา: [13](issues/13-data-storage.md) รูปแบบไฟล์ดู [ภาคผนวก P1](#p1-ไฟล์ข้อมูล-version-1) กติการ่วมของทุกไฟล์:

- โฟลเดอร์ `~/Library/Application Support/com.teppasit.pomodot/` (App สร้างถ้ายังไม่มี) ใช้ `Codable` + `JSONEncoder`/`JSONDecoder` **ไม่ใช้ UserDefaults, SwiftData, SQLite**
- **Core:** กำหนดรูปแบบไฟล์, แปลงข้อมูล ↔ JSON, ไม่มีไฟล์ → ค่าเริ่มต้น, อ่านไม่ออก → ค่าเริ่มต้น + บอก App ให้ย้ายไฟล์, แปลงเวอร์ชันเก่า, ตรวจค่าทีละค่า **App:** รู้ที่อยู่โฟลเดอร์, อ่าน/เขียนดิสก์, ย้ายไฟล์เสีย
- เขียนแบบ **atomic** ทุกไฟล์ (`Data.write(to:options: .atomic)`)
- **ไฟล์อ่านไม่ออก** (JSON เสีย หรือ `version` สูงกว่าที่รู้จัก) → เปลี่ยนชื่อเป็น `<ชื่อ>.corrupt-<yyyy-MM-dd'T'HH-mm-ss>.json` ในโฟลเดอร์เดิม แล้วใช้ค่าเริ่มต้น **ห้ามเขียนทับไฟล์เสีย** ไม่แสดงกล่องแจ้งเตือน เขียนลง log ของระบบอย่างเดียว
- **อ่านได้แต่บางค่าหาย/ผิด** → แก้แค่ค่านั้นเป็นค่าเริ่มต้น ค่าอื่นเก็บไว้ (History: ข้ามแค่รายการที่เสีย)
- ทุกไฟล์มี `"version": 1` เพิ่มค่าใหม่ไม่ต้องเพิ่มเลข (ไฟล์เก่าที่ไม่มีค่านั้นใช้ค่าเริ่มต้น) เพิ่มเลขเฉพาะตอนเปลี่ยนโครงสร้าง (เปลี่ยนชื่อ/หน่วย) และต้องมีโค้ดแปลง + test
- ไม่รองรับ downgrade (แอพเก่าเจอ version สูงกว่า → ใช้กติกาไฟล์อ่านไม่ออก)
- **`state.json` บันทึกเป็น "ภาพตอน Pause ณ เวลาที่บันทึก" เสมอ** (Running ถูกบันทึกเป็นเวลาที่เหลือ ณ ตอนนั้น) โหลดกลับมาเป็น Paused ได้เอง
- บันทึกเมื่อ: สถานะเปลี่ยน (ปุ่ม, จบ Phase, auto-pause, เปลี่ยน Settings, ซ่อน/แสดง/ลาก Floating Window, สลับ Always on Top) **+ ทุก 30 วิระหว่าง Running** + ตอน Quit (Force Quit / crash / ไฟดับ เสียเวลาไม่เกิน 30 วิ)

### Test (Core) M2
**Timer (seam 1)** ใช้ค่าเริ่มต้น 25/5/15/4, auto-start ปิด เว้นแต่ระบุ
- ลำดับปกติ: Focus 1/4 ครบ → Short Break 1/4 Ready; Focus 4/4 ครบ → Long Break 4/4; Long Break ครบ → Focus 1/4 Ready, `done` = 0
- Skip Focus 2/4 (done 1) → Short Break 2/4, done ยัง 1, Focus ถัดไปคือ 2/4
- Skip Focus 4/4 (done 3) → Short Break 4/4 (ไม่ใช่ Long Break)
- Skip Short Break 2/4 (หลัง Focus 2 ครบ) → Focus 3/4
- Skip Long Break → Focus 1/4 ของ Cycle ใหม่ done 0 Ready (แม้ auto-start Focus เปิด)
- Reset Focus 2/4 ที่เหลือ 10:00 → Focus 2/4 เต็ม 25:00 Ready, done ไม่เปลี่ยน, ไม่มี Pomodoro
- Reset ใช้ความยาวจาก Settings ล่าสุด (เปลี่ยน Focus เป็น 30 ระหว่างเดิน แล้ว Reset → 30:00)
- New Cycle จาก Short Break 3/4 → Focus 1/4 Ready done 0
- Pause ที่ 09:00 ตอนเหลือ 20:00, Resume ที่ 09:10 → ที่ 09:15 เหลือ 15:00
- Focus ที่ Pause กลางทางแล้วทำต่อจนครบ → เป็น Pomodoro
- Focus ที่เริ่ม 09:00 เวลา 25 นาที ไม่ Pause, tick ที่ 09:25:03 → Pomodoro จบเวลา 09:25:00 (ไม่ใช่ 09:25:03)
- auto-start Break เปิด: Focus ครบตอน 09:25:00 → Short Break Running เริ่ม 09:25:00
- auto-start Focus เปิด: Short Break ครบ → Focus Running; Long Break ครบ → Focus 1/4 **Ready**
- ทั้งคู่เปิด, tick มาช้า: Focus เริ่ม 09:00 (เหลือ 25:00) tick แรกมาตอน 09:31 → ได้ Pomodoro 1 อัน (จบ 09:25), Short Break จบ 09:30, ตอนนี้เป็น Focus 2/4 Running เหลือ 24:00
- sleep ตอน Running → Paused ด้วยเวลาที่เหลือ ณ ตอน sleep ไม่มี Pomodoro ไม่มีแจ้งเตือน
- เปิดแอพใหม่จาก state ที่เป็น Running → Paused
- เปลี่ยน Focus เป็น 30 ตอน Focus 2/4 Running → Phase นี้ยังเป็น 25 นาที, Focus 3/4 เป็น 30:00
- เปลี่ยน Focus เป็น 30 ตอน Focus 1/4 Ready (ยังไม่เคย Start) → เป็น 30:00 ทันที
- เปลี่ยน N เป็น 6 ตอน Focus 2/4 → ยังเป็น x/4 จนจบ Cycle, Cycle ถัดไปเป็น 1/6
- เปลี่ยน N เป็น 6 ตอน Focus 1/4 Ready done 0 → เป็น 1/6 ทันที
- ถามยืนยัน: Reset ตอน Ready → ไม่ถาม; ตอน Running/Paused → ถาม; New Cycle ตอน Focus 1/4 Ready done 0 → ไม่ถาม; Focus 2/4 Ready (done 1) → ถาม; Short Break 1/4 Ready ที่ done 0 (หลัง Skip Focus 1/4) → ไม่ถาม
- กดไม่ได้: Focus 1/4 Ready done 0 → Reset และ New Cycle สีจาง; Short Break 1/4 Ready done 0 (หลัง Skip Focus 1/4) → Reset สีจาง New Cycle กดได้; Focus 2/4 Ready done 1 → Reset สีจาง New Cycle กดได้; Running/Paused → กดได้ทั้งคู่
- **Expected finish** (ตัวอย่าง ค่าเริ่มต้น 25/5/15/4):

  | สถานการณ์ | now | Phase ends | Cycle ends |
  |---|---|---|---|
  | Focus 1/4 Ready เต็มเวลา | 09:00 | 09:25 | 11:10 |
  | Focus 2/4 Running (done 1) เหลือ 10:00 | 14:00 | 14:10 | 15:25 |
  | ข้อบน แต่ผ่านไป 5 นาทีโดยไม่ Pause (เหลือ 05:00) | 14:05 | 14:10 | 15:25 (นิ่ง) |
  | Focus 2/4 Paused เหลือ 10:00 | 14:20 | 14:30 | 15:45 (เลื่อน) |
  | Skip Focus 2/4 (done 1) ตอน 14:00 → Short Break 2/4 Ready | 14:00 | 14:05 | 15:45 |
  | Short Break 2/4 Ready หลัง Focus 2/4 ครบ (done 2) | 14:00 | 14:05 | 15:15 |
  | Long Break 4/4 Running เหลือ 07:00 | 16:00 | 16:07 | 16:07 |
  | Focus 2/4 Running เหลือ 10:00 แล้วเปลี่ยน Settings เป็น Focus 30 นาที, 6 ต่อ Cycle | 14:00 | 14:10 | 15:35 (Focus ที่เหลือ 30 นาที แต่ Cycle นี้ยังเป็น 4) |
  | Focus 2/4 Running ที่ถึงเวลาจบ 14:10 แล้วแต่ยังไม่มี tick | 14:10:30 | 14:10 | 15:25 (นิ่ง) |

**Floating Window (seam 4)** พื้นที่ใช้งานของจอ (0, 0)–(1440, 875) แกน y ชี้ขึ้น, แคปซูล 128×38, การ์ด 284×200
- กึ่งกลางแคปซูล (720, 850) → ขยายลง การ์ด x 578–862, y 669–869
- กึ่งกลาง (720, 60) → ขยายขึ้น การ์ด x 578–862, y 41–241
- กึ่งกลาง (720, 450) ไม่ใกล้ขอบไหน → ขยายจากตรงกลาง การ์ด x 578–862, y 350–550
- กึ่งกลาง (1370, 850) → ขยายลง ชิดขวา การ์ด x 1150–1434
- กึ่งกลาง (70, 850) → ขยายลง ชิดซ้าย การ์ด x 6–290
- ทิศที่เลือกไม่เปลี่ยนจนกว่าจะหุบ
- ตำแหน่งที่จำไว้ (2000, 500) ไม่อยู่ในจอไหนเลย → ตำแหน่งเริ่มต้น (720, ขอบบน 863)
- ตำแหน่งที่จำไว้ (300, 400) อยู่ในจอ → ใช้ตำแหน่งนั้น
- ลากไปเกินขอบ → ถูกจำกัดให้อยู่ในพื้นที่ใช้งาน
- เมาส์เข้า t=0 ยังอยู่ถึง t=2 → ไม่ขยาย (ต้องคลิก)
- ขยายอยู่ ออก t=0 → หุบที่ t=0.5; ออก t=0 กลับ t=0.4 → ไม่หุบ
- กดแล้วปล่อยโดยไม่เลื่อน → ขยายทันที
- กดแล้วลาก → ไม่ขยายระหว่างลากและหลังปล่อย, คลิกอีกครั้ง → ขยาย

**ข้อมูล (seam 5) ส่วน state**
- บันทึกแล้วโหลดกลับได้ค่าเดิมครบ
- state ที่บันทึกตอน Running โหลดกลับมาเป็น Paused ด้วยเวลาที่เหลือ ณ ตอนบันทึก
- N ของ Cycle ปัจจุบันยังเป็นค่าเดิม แม้ Settings จะเปลี่ยนไปแล้ว (ไม่กลายเป็น "2/6")
- ไม่มีไฟล์ → Focus 1/4 เต็มเวลา Ready, Floating Window แสดง, Always on Top เปิด, ตำแหน่งเริ่มต้น
- ไฟล์อ่านไม่ออก / `version` = 2 → ค่าเริ่มต้น + บอกให้ย้ายไฟล์ไว้ข้างๆ (ชื่อไฟล์ตามรูปแบบ corrupt)
- ขาดบางค่า / ค่าผิด (เช่น `remainingSeconds` = -5) → แก้แค่ค่านั้น
- ไฟล์ตัวอย่าง `state.json` version 1 จาก P1 อ่านได้ถูกต้องเสมอ

### Checklist ทดสอบด้วยมือ M2
- menu bar ทั้งแบบสีอ่อนและสีเข้ม: Focus เดิน → `timer` + เวลา, Break เดิน → `cup.and.saucer.fill` + เวลา, Pause → `pause.circle` + เวลาจาง, Ready → ไอคอนของ Phase ที่รอ ไม่มีเวลา ไอคอนเปลี่ยนสีตาม menu bar
- เวลาบน menu bar อัปเดตทุกวินาทีและตัวเลขไม่ขยับไปมา
- เมนูควบคุมได้ครบ (Start/Pause/Resume, Skip, Reset…, New Cycle…) และ Expected finish ในเมนูตรงกับบนการ์ด
- กล่องยืนยัน Reset / New Cycle ขึ้นมาด้านหน้าเสมอ (ลองตอนอยู่ในแอพอื่น)
- ชี้ที่แคปซูลแล้วกว้างขึ้นนิดหนึ่งแต่ไม่ขยาย, คลิกแล้วขยายทันที, เอาเมาส์ออกแล้วหุบ
- ลากแคปซูลแล้วไม่ขยาย
- ลากแคปซูลไปชิดขอบล่าง/ขวาแล้วคลิก → การ์ดไม่ทะลุจอและไม่ทับ Dock
- คลิกพื้นที่ว่างรอบๆ แคปซูล (ใกล้ๆ แต่ไม่โดนกระจก) ทั้งตอนเปิดและปิด Always on Top → คลิกทะลุไปถึงแอพข้างหลัง
- ตอน Pause ตัวเลข "หายใจ" + `PAUSED`
- เปลี่ยน Phase แล้วเด้งครั้งเดียว สีค่อยๆ เปลี่ยน ไม่กะพริบ
- เปิด Reduce motion แล้วไม่มี animation
- ล็อกจอระหว่าง Focus (Ctrl-Cmd-Q) → ปลดล็อกแล้ว timer เดินต่อ
- ปิดฝา/สั่ง Sleep ระหว่าง Focus → ตื่นมาเป็น Pause
- เปิดแอพซ้ำจาก Finder ตอนรันอยู่ (และซ่อน Floating Window ไว้) → Floating Window โผล่ ไม่มีแอพตัวที่สอง
- Quit กลาง Focus แล้วเปิดใหม่ → ทุกอย่างเหมือนเดิม เป็น Pause
- Force Quit กลาง Focus แล้วเปิดใหม่ → เวลาคลาดไม่เกิน 30 วิ เป็น Pause
- ซ่อน Floating Window แล้ว Quit และเปิดใหม่ → ยังซ่อนอยู่
- ลากแคปซูลไปมุมจอ แล้ว Quit และเปิดใหม่ → อยู่ที่เดิม
- (ถ้ามีจอเสริม) ลากแคปซูลไปจอเสริม Quit ถอดจอ แล้วเปิดใหม่ → แคปซูลกลับมากลางบนของจอหลัก

---

## M3. แจ้งเตือน + เสียง

branch: `feature/m3-notifications` ที่มา: [08](issues/08-notification-and-sound.md)

### ช่องทาง
- Phase **หมดเวลาเอง** → **banner notification ของ macOS + เสียง**
- banner ต้อง**ขึ้นทุกครั้งแม้แอพเป็นแอพที่ active อยู่** (ค่าเริ่มต้นของ macOS ไม่แสดง ต้องใช้ `UNUserNotificationCenterDelegate.userNotificationCenter(_:willPresent:withCompletionHandler:)` ตอบ `.banner` + `.list`)
- **ไม่มีแจ้งเตือนและไม่มีเสียง**ตอน Skip / Reset / New Cycle / auto-pause ตอน sleep
- Floating Window แค่เปลี่ยนไปแสดง Phase ถัดไป (+ animation เด้ง M2) ไม่กะพริบ ไม่เปลี่ยนสีเพื่อแจ้งเตือน

### เสียง
- **เสียงระบบของ macOS** ดัง**ครั้งเดียว** ไม่ดังซ้ำ ไม่มีเสียงติ๊กระหว่าง Focus
- **แอพเล่นเสียงเอง** (`NSSound(named:)`) **ไม่ใส่เสียงไว้ใน notification** เสียงจึงยังดังแม้ปิด notification, ไม่ได้ให้สิทธิ์ หรือเปิด Focus / Do Not Disturb ของ macOS อยู่ (เหมือนนาฬิกาปลุกที่ตั้งเอง ไม่ใช่บั๊ก) ส่วน banner เป็นไปตามกติกา macOS (โดนซ่อนตอน Do Not Disturb)
- 2 ช่อง: จบ Focus = **Glass**, จบ Break (Short และ Long) = **Hero** (ค่าเริ่มต้น เลือกเปลี่ยนได้ใน M5)
- ใช้ความดังของเครื่อง ไม่มีปุ่มปรับความดัง

### ขอสิทธิ์
- ขอตอน**กด Start ครั้งแรกสุด** (ไม่ใช่ตอนเปิดแอพ) timer เริ่มเดินทันทีโดยไม่รอคำตอบ
- ใช้กล่อง Allow / Don't Allow แบบปกติ **ไม่ใช้ provisional** (โหมดนั้นไม่ขึ้น banner)
- กด Don't Allow → แอพใช้ได้ปกติ เสียงยังดัง **ไม่มี popup ถามซ้ำ** และมีบรรทัดเตือนใน Settings (M5)
- ถ้าผู้ใช้ปิด `Show notifications` ในแอพ (M5) → ไม่ขอสิทธิ์ ไม่ส่ง banner ไม่โชว์บรรทัดเตือน

### ข้อความ banner (seam 3)
ตัวเลขเป็นค่าจริงจาก Settings และ Cycle เนื้อความเปลี่ยนตามว่า Phase ถัดไปเริ่มเองหรือรอกด Start

| เหตุการณ์ | หัวข้อ | เนื้อความ (รอกด Start) | เนื้อความ (เริ่มเอง) |
|---|---|---|---|
| Focus จบ → Short Break | `Focus complete 🍅 2/4` | `Time for a 5-minute Short Break.` | `5-minute Short Break started.` |
| Focus จบ → Long Break | `Cycle complete 🍅 4/4` | `Time for a 15-minute Long Break.` | `15-minute Long Break started.` |
| Short Break จบ → Focus | `Break over` | `Time for Focus 3/4.` | `Focus 3/4 started.` |
| Long Break จบ | `Long Break over` | `Ready for a new Cycle.` | (ไม่มีกรณีนี้ หยุดรอเสมอ) |

### พฤติกรรมของ banner
- banner ใหม่**ทับอันเก่า** (ใช้ request identifier เดียวกันทุกครั้ง) Notification Center เหลือแค่อันล่าสุด
- **คลิก banner = แสดง Floating Window** (ถ้าซ่อนอยู่) ไม่ขัดกับ "ไม่เด้งกลับมาเอง" เพราะผู้ใช้คลิกเอง
- ไม่มีปุ่ม action บน banner

### Test (Core) M3 (seam 3)
- 4 เหตุการณ์ × (เริ่มเอง / รอกด) ได้หัวข้อและเนื้อความตรงตารางข้างบน (ใช้ค่า 25/5/15/4)
- ใช้ค่าจริง: Short Break 7 นาที → `Time for a 7-minute Short Break.`; N = 6 จบ Focus 6 → `Cycle complete 🍅 6/6`
- Skip / Reset / New Cycle / auto-pause → ไม่แจ้งเตือน
- `Show notifications` ปิด → ไม่มี banner แต่ยังต้องเล่นเสียง (เสียงของช่องที่ถูก: จบ Focus = ช่อง Focus, จบ Short/Long Break = ช่อง Break)

### Checklist ทดสอบด้วยมือ M3
- กล่องขอสิทธิ์ notification ขึ้นตอนกด Start ครั้งแรก ไม่ใช่ตอนเปิดแอพ
- Focus หมดเวลา → banner ขึ้นพร้อมไอคอนแบบ A ชื่อ `Pomodot` และได้ยินเสียง Glass; Break หมด → เสียง Hero
- banner ขึ้นแม้ Pomodot เป็นแอพที่ใช้อยู่ (เช่น ตอนเปิดเมนูค้างไว้)
- System Settings › Notifications มีรายการ `Pomodot` พร้อมไอคอน
- คลิก banner ตอน Floating Window ซ่อนอยู่ → Floating Window โผล่
- เปิด Do Not Disturb → banner ไม่ขึ้น แต่เสียงยังดัง
- กด Don't Allow (ทดสอบด้วยการลบสิทธิ์ใน System Settings) → เสียงยังดัง ไม่มี popup ถามซ้ำ
- Skip / Reset ไม่มี banner และไม่มีเสียง

---

## M4. History + Statistics

branch: `feature/m4-statistics` ที่มา: [09](issues/09-what-stats-mean.md)

### History
- เก็บแค่ **Pomodoro** แต่ละอันมี**เวลาจบ** (เวลาสากล ISO 8601 UTC ปัดเป็นวินาที) และ**ความยาว** (วินาที) ต้องเก็บความยาวเพราะผู้ใช้เปลี่ยนเวลา Focus ได้
- บันทึก**ตอน Focus หมดเวลา** (ใช้เวลาจบตามกำหนด A6)
- Focus ที่ Skip / Reset / New Cycle **ไม่เก็บ** (ยอมรับว่าทำ completion rate ไม่ได้)
- **New Cycle ไม่ลบ History**
- เก็บ**ตลอดไป** ไม่ลบอัตโนมัติ
- `history.json` บันทึกทุกครั้งที่ได้ Pomodoro และตอน Clear History (เขียนทั้งไฟล์ใหม่แบบ atomic) รูปแบบดู P1
- ลำดับตอนจบ Focus: **บันทึก History ก่อน state เสมอ** (ถ้าแอพดับระหว่าง 2 ขั้นนี้ อาจได้ Pomodoro ซ้ำ 1 อัน ยอมรับได้ ไม่ต้องกันเพิ่ม)

### ตัดวันกับสัปดาห์
- วันใหม่เริ่ม**เที่ยงคืนตามเวลาเครื่อง** Pomodoro ที่คร่อมเที่ยงคืนนับเป็น**วันที่จบ**
- วันแรกของสัปดาห์ตามการตั้งค่าเครื่อง (`Calendar.current.firstWeekday` จาก Language & Region) แอพไม่มีสวิตช์ของตัวเอง
- แบ่งวันตาม**โซนเวลาปัจจุบัน**ของเครื่องตอนแสดงผล (ย้ายโซนแล้วบางอันย้ายวัน ยอมรับได้)

### เมนู: `Today: 🍅 5`
- บรรทัดบนสุดของเมนู กดไม่ได้ นับจำนวน Pomodoro ของวันนี้อย่างเดียว (ไม่มีเวลารวม)
- เป็น 0 เองตอนเที่ยงคืน (ฟัง `NSCalendarDayChanged` และการเปลี่ยนโซนเวลา)

### หน้าต่าง Statistics
- เปิดจากเมนู `Statistics…` หน้าต่างปกติ (ไม่ลอยบนสุด มีปุ่มปิดสีแดง) `NSApp.activate()` ก่อนแสดงให้มาอยู่ด้านหน้า สไตล์ตาม A10

```
┌─ Statistics ────────────────────────────┐
│   Today        This Week     All Time   │
│   🍅 5         🍅 23         🍅 412     │
│   2h 05m       9h 35m        171h 40m   │
│                                         │
│   Last 7 Days                           │
│    ▇                                    │
│    ▇     ▇           ▇                  │
│    ▇  ▇  ▇     ▇  ▇  ▇                  │
│   Thu Fri Sat Sun Mon Tue Today         │
│                                         │
│                       [Clear History…]  │
└─────────────────────────────────────────┘
```

- **การ์ด 3 ใบเรียงแนวนอน:** Today / This Week / All Time แต่ละใบมีจำนวน Pomodoro + เวลา Focus รวม รูปแบบ `2h 05m` ไม่ถึงชั่วโมงเป็น `45m` (ไม่มีเลยเป็น `0m`)
- **กราฟแท่ง 7 วันล่าสุด** (รวมวันนี้) ด้วย **Swift Charts** ในกล่องโค้ง ความสูง = จำนวน Pomodoro วันที่ไม่มีก็มีช่องแค่ไม่มีแท่ง แท่งของวันนี้สีเข้ม วันอื่นสีอ่อนลง ช่องสุดท้ายเขียนว่า `Today` ชี้ที่แท่งแล้วเห็น `8 🍅 · 3h 20m`
- เปิดค้างไว้ → ตัวเลขกับกราฟอัปเดตเองทันทีที่ได้ Pomodoro ใหม่ และตอนข้ามเที่ยงคืน
- **`Clear History…`** ชิดขวาล่าง กดแล้วมีกล่องยืนยันแบบ sheet (เลื่อนลงจากด้านบนของหน้าต่าง) บอกจำนวน: หัวข้อ `Delete all 412 Pomodoros?` เนื้อความ `This can't be undone.` ปุ่ม `Delete` / `Cancel` History ว่างอยู่ → ปุ่มกดไม่ได้ ลบแล้ว**ไม่กระทบ timer** (Phase, ตัวนับ, เวลาที่เหลือยังอยู่) แต่ `Today` เป็น 0

### Test (Core) M4
**History / Statistics (seam 2)** ใช้ TimeZone `Asia/Bangkok` (UTC+7) เว้นแต่ระบุ
- Pomodoro จบ `2026-10-14T17:10:00Z` (= 00:10 ของ 15 ต.ค. เวลาไทย) ความยาว 1500 วิ → นับเป็นวันที่ 15 ต.ค.
- now = 2026-10-14 (วันพุธ) 12:00 เวลาไทย, firstWeekday = จันทร์ → This Week เริ่ม 12 ต.ค.; firstWeekday = อาทิตย์ → เริ่ม 11 ต.ค.
- เวลารวมมาจากความยาวของแต่ละอัน: 1500 + 1800 + 1200 = 4500 วิ → `1h 15m`; 125 นาที → `2h 05m`; 45 นาที → `45m`; 0 → `0m`; 10300 นาที → `171h 40m`
- กราฟ 7 วัน: มี Pomodoro เฉพาะวันนี้กับ 3 วันก่อน → ได้ 7 ช่อง ช่องที่ไม่มีเป็น 0
- Focus ที่ Skip / Reset ไม่ถูกบันทึก (ผ่าน seam 1: ไม่มี Pomodoro ออกมา)
- New Cycle ไม่ลบ History
- Clear History → History ว่าง, Today = 0, state ของ timer ไม่เปลี่ยน

**ข้อมูล (seam 5) ส่วน history**
- บันทึกแล้วโหลดกลับได้ค่าเดิมครบ
- ไม่มีไฟล์ → History ว่าง
- ไฟล์อ่านไม่ออก → History ว่าง + บอกให้ย้ายไฟล์ไว้ข้างๆ
- มีรายการเสีย 1 รายการ (เช่น ไม่มี `end`) → ข้ามแค่รายการนั้น
- History 5,000 รายการ บันทึกแล้วโหลดกลับได้ครบ เวลาจบตรงเป๊ะ
- ไฟล์ตัวอย่าง `history.json` version 1 จาก P1 อ่านได้ถูกต้องเสมอ

### Checklist ทดสอบด้วยมือ M4
- เปิดหน้าต่าง Statistics ค้างไว้แล้วทำ Pomodoro ให้ครบ 1 อัน (ใช้เวลา 25 นาที) → `Today` ในเมนูเพิ่มขึ้น และตัวเลขกับกราฟใน Statistics อัปเดตเอง
- ทำ Pomodoro ครบแล้ว Quit และเปิดใหม่ → Statistics ยังนับครบ
- `Today` กลับเป็น 0 ตอนเที่ยงคืน (หรือเปลี่ยนเวลาเครื่องข้ามเที่ยงคืน ถ้าใช้วิธีนี้ให้ทดสอบตอน timer เป็น Ready เพราะการเปลี่ยนนาฬิกาทำให้เวลาที่เหลือของ timer เปลี่ยนไปด้วย)
- กล่องยืนยัน Clear History ขึ้นมาด้านหน้า บอกจำนวนถูก และปุ่มกดไม่ได้ตอน History ว่าง
- Clear History แล้ว timer ยังอยู่ที่เดิม

---

## M5. Settings + Appearance + แจกจ่าย

branch: `feature/m5-settings-release` แล้วออก `release/0.9.0`

### หน้าต่าง Settings
ที่มา: [07](issues/07-menubar-vs-floating.md), [08](issues/08-notification-and-sound.md), [10](issues/10-floating-window-look.md)

เปิดจากเมนู `Settings…` หน้าต่างปกติ (ไม่ลอย มีปุ่มปิดสีแดง) แยกจาก Statistics `NSApp.activate()` ก่อนแสดง ฟอร์มหน้าเดียว สไตล์กล่องมุมโค้งแบบ System Settings (A10):

```
Timer
  Focus               [ 25 ] min  ⇅
  Short Break         [  5 ] min  ⇅
  Long Break          [ 15 ] min  ⇅
  Pomodoros per Cycle [  4 ]      ⇅

Auto-start
  [ ] Start breaks automatically
  [ ] Start Focus automatically
      (never after a Long Break)

Notifications & Sound
  [✓] Show notifications
      ⚠ Notifications are turned off for Pomodot in System Settings.
        [Open System Settings…]           ← ขึ้นเฉพาะตอนระบบปิดสิทธิ์ไว้
  End of Focus sound   [ Glass ▾ ]
  End of Break sound   [ Hero  ▾ ]

Appearance
  ( System | Light | Dark )

                      [Restore Defaults]
```

- เวลาแต่ละ Phase 1–120 นาที (จำนวนเต็ม), Pomodoros per Cycle 1–10 ใช้ช่องตัวเลข + ปุ่มขึ้น/ลง
- **เปลี่ยนแล้วมีผลทันที ไม่มีปุ่ม Save** (มีผลกับ Phase ไหนตามกติกา M2)
- บรรทัดเตือนสิทธิ์เป็น**สีส้ม**อยู่ใต้ `Show notifications` (ใช้ SF Symbol `exclamationmark.triangle.fill`) ขึ้นเฉพาะตอน `Show notifications` เปิด และระบบปิดสิทธิ์ (เช็กด้วย `getNotificationSettings` ตอนเปิดหน้าต่างและตอนแอพกลับมา active) `[Open System Settings…]` เปิดหน้า Notifications ของ System Settings (URL scheme ที่น่าจะใช้ได้คือ `x-apple.systempreferences:com.apple.Notifications-Settings.extension` ต้องลองเปิดจริงก่อน)
- dropdown เสียงมีเสียงระบบทุกตัว (ไฟล์ใน `/System/Library/Sounds` ใช้ชื่อไม่มีนามสกุล) และ `None` อยู่บนสุด **เลือกแล้วเล่นให้ฟังทันที** ไม่มีปุ่มเล่นแยก ไม่มีสวิตช์ปิดเสียงทั้งหมด (อยากเงียบเลือก `None`) ถ้าชื่อเสียงที่บันทึกไว้ไม่มีในเครื่อง ใช้ค่าเริ่มต้นของช่องนั้น
- **Appearance** `System` / `Light` / `Dark` ค่าเริ่มต้น `System` มีผลกับ**ทุกหน้าต่างรวมถึงแคปซูล**ทันที (`NSApp.appearance`) เลือก System แล้วเครื่องสลับโหมด → แอพเปลี่ยนตามทันที
- **Restore Defaults** (ชิดขวาล่าง): 25 / 5 / 15 / 4, ปิด auto-start ทั้งสอง, เปิด `Show notifications`, เสียง Glass / Hero, Appearance System **ไม่แตะ**ตำแหน่ง Floating Window, ซ่อน/แสดง และ Always on Top (ไม่อยู่ในหน้า Settings)

### ข้อมูล: `settings.json`
- เก็บทุกค่าในหน้า Settings บันทึกทุกครั้งที่เปลี่ยน รูปแบบดู P1 กติการ่วมตาม M2

### About / Check for Updates ([15](issues/15-versioning-and-release.md))
- `About Pomodot` = หน้าต่าง About มาตรฐานของ macOS (`NSApp.orderFrontStandardAboutPanel`) โชว์ไอคอน ชื่อ และ `0.9.0 (build N)`
- `Check for Updates…` = เปิด `https://github.com/inwpasit619/pomodot/releases` ใน browser แอพ**ไม่ต่อเน็ตเอง** ไม่มี auto-update (URL เป็นค่าคงที่ใน App ไม่ต้องมี test)

### แจกจ่าย ([02](issues/02-run-unsigned-app-gatekeeper.md), [15](issues/15-versioning-and-release.md))

**เลข version**
- `MAJOR.MINOR.PATCH` แก้บั๊ก = PATCH, เพิ่มฟีเจอร์ = MINOR, เปลี่ยนใหญ่ = MAJOR
- **เวอร์ชันแรกที่แจกคือ `0.9.0`** ออกตอนจบ M5 เพื่อนเจอบั๊ก → `0.9.1`, `0.9.2`… ผู้ใช้พอใจเมื่อไหร่ค่อย `1.0.0`
- ผู้ใช้บอก "ออก release" → agent เสนอเลขถัดไปพร้อมเหตุผล → ผู้ใช้อนุมัติแล้วค่อยเริ่ม
- tag `v<version>` ไฟล์ `Pomodot-<version>.zip`

**`scripts/release.sh`** ใช้ `build-app.sh` ตัวเดิม แล้วต่อด้วยขั้นเหล่านี้ **ข้อไหนไม่ผ่านให้หยุดทันที ห้ามอัปโหลด**
1. อยู่บน `main` ที่ merge `release/X.Y.Z` หรือ `hotfix/X.Y.Z` แล้ว ไม่มีงานค้างที่ยังไม่ commit และยังไม่มี tag `vX.Y.Z` ทั้งในเครื่องและบน GitHub
2. ผ่านเงื่อนไข "เสร็จ" ทั้ง 7 ข้อ (A8)
3. executable มีทั้ง `arm64` และ `x86_64` (`lipo -archs`)
4. `codesign --verify --strict --deep Pomodot.app` ผ่าน
5. `ditto -c -k --keepParent Pomodot.app Pomodot-X.Y.Z.zip` แล้ว**แตกลงโฟลเดอร์ชั่วคราวด้วย `ditto -x -k` และรัน `codesign --verify --strict --deep` ซ้ำ** (ลายเซ็นเสีย = เพื่อนเจอ "damaged" ที่ไม่มีปุ่ม Open Anyway)
6. **ห้ามใช้ `spctl --assess` เป็นตัวตัดสิน** (แอพที่ไม่ notarize ยังไงก็ `rejected`)
7. โชว์ release notes ที่ร่างไว้ให้ผู้ใช้ → ผู้ใช้อนุมัติ → tag `vX.Y.Z`, push `main` + tag + `develop` → `gh release create vX.Y.Z Pomodot-X.Y.Z.zip --title "Pomodot X.Y.Z" --notes-file …` (**ไม่ใส่ `--prerelease`** ให้ `releases/latest` ชี้เวอร์ชันล่าสุดเสมอ) → `gh release download` กลับมาแล้วเทียบ `shasum -a 256` ต้องตรงกับไฟล์ในเครื่อง

**Release notes** ภาษาอังกฤษอย่างเดียว agent ร่างจาก commit ตั้งแต่ tag ก่อนหน้า เขียนเป็นภาษาคน (ไม่ใช่ชื่อ commit) 3 ส่วน: **What's new / Fixed**, **Install or update** (สั้นๆ แล้วลิงก์ไป README), **Your data is kept** (เอาไปทับแอพเดิมได้ History กับ Settings ยังอยู่) **ผู้ใช้ต้องอนุมัติก่อนเผยแพร่ทุกครั้ง** (repo public)

**README** ดู [ภาคผนวก P2](#p2-readme)

**ทดสอบ Open Anyway ตอนอัปเดต (บนเครื่อง dev)**
- research **คาดว่า**อัปเดตแล้วต้องกด Open Anyway ซ้ำ (ยังไม่ได้ยืนยัน) ต้องทดสอบให้รู้จริง:
- agent ทำ build ทดสอบ 2 ตัวที่ `CFBundleVersion` ต่างกัน zip แล้วใส่ quarantine ให้เหมือนดาวน์โหลดผ่าน browser: `xattr -w com.apple.quarantine "0081;$(printf %x $(date +%s));Safari;" <zip>` ก่อนให้ผู้ใช้แตกไฟล์ด้วย Finder
- ผู้ใช้ติดตั้งตัวแรก → กด Open Anyway → เอาตัวที่สองไปทับ → ดูว่า macOS บล็อกอีกไหม
- เขียน README และ release notes ตามผลจริง บันทึกผลในรายงาน M5

**ข้อมูลตอนลบ/อัปเดตแอพ** ([13](issues/13-data-storage.md))
- แอพไม่มี sandbox ข้อมูลอยู่แยกจากตัวแอพ: **ลบแอพ → ข้อมูลยังอยู่** ลงใหม่ก็กลับมาครบ **อัปเดตด้วยการเอาแอพใหม่ไปทับ → ข้อมูลยังอยู่** (ตราบใดที่ bundle id ไม่เปลี่ยน)
- **ไม่มี**ปุ่ม "ลบข้อมูลทั้งหมด" หรือ "Show Data Folder" ในแอพ

### Test (Core) M5
**ข้อมูล (seam 5) ส่วน settings**
- บันทึกแล้วโหลดกลับได้ค่าเดิมครบ
- ไม่มีไฟล์ → 25/5/15/4, auto-start ปิดทั้งคู่, Show notifications เปิด, Glass / Hero, Appearance System
- ไฟล์ไม่มี `appearance` → ใช้ System ค่าอื่นเหมือนเดิม
- `focusMinutes` = -5 หรือ 121 → ใช้ 25 ค่าอื่นเหมือนเดิม; `pomodorosPerCycle` = 0 หรือ 11 → ใช้ 4
- ไฟล์อ่านไม่ออก / `version` สูงกว่า → ค่าเริ่มต้น + บอกให้ย้ายไฟล์
- ไฟล์ตัวอย่าง `settings.json` version 1 จาก P1 อ่านได้ถูกต้องเสมอ
- Restore Defaults คืนค่าแค่ settings ไม่แตะ state ของ Floating Window

### Checklist ทดสอบด้วยมือ M5
- เปลี่ยนเวลา/สวิตช์ใน Settings แล้วมีผลทันทีตามกติกา (ไม่มีปุ่ม Save)
- เลือกเสียงใน dropdown แล้วได้ยินทันที, เลือก `None` แล้วหมด Phase ไม่มีเสียง
- ระบบปิดสิทธิ์ notification → บรรทัดเตือนสีส้มขึ้นใต้ `Show notifications`, กด `Open System Settings…` แล้วไปหน้า Notifications
- Appearance เป็น System แล้วสลับโหมดเครื่อง → ทุกหน้าต่างรวมแคปซูลเปลี่ยนตามทันที; เลือก Light/Dark → ไม่สนโหมดเครื่อง
- Restore Defaults → ค่าใน Settings กลับเป็นค่าเริ่มต้น แคปซูลไม่ย้าย
- เมนู › About Pomodot → เห็นไอคอน ชื่อ และ `0.9.0`
- เมนู › Check for Updates… → browser เปิดหน้า Releases ของ `inwpasit619/pomodot`
- อัปเดตทับ (ทดสอบ Open Anyway ข้างบน) → History กับ Settings ยังอยู่ และรู้แล้วว่าต้องกด Open Anyway ซ้ำไหม
- ลบแอพแล้วลงใหม่ → History ยังอยู่; ลบโฟลเดอร์ข้อมูลตามขั้นตอนใน README → เริ่มใหม่สะอาด
- เครื่องเพื่อน: ดาวน์โหลด `Pomodot-0.9.0.zip` จาก `releases/latest` → ลากไป Applications → Open Anyway (เห็นชื่อ `Pomodot`) → ใช้งานได้

---

# ภาคผนวก

## P1. ไฟล์ข้อมูล version 1

ที่มา: [13](issues/13-data-storage.md) ชื่อ key ด้านล่าง spec นี้กำหนด ให้ใช้ตามนี้และ copy 3 ไฟล์นี้ไปเป็น fixture ที่ `Tests/CoreTests/Fixtures/` (เพื่อจับกรณีที่เผลอเปลี่ยนรูปแบบไฟล์) ทุกเวลาเป็น ISO 8601 UTC ไม่มีเศษวินาที ทุกความยาวเป็นวินาที

**`settings.json`**
```json
{
  "version": 1,
  "focusMinutes": 25,
  "shortBreakMinutes": 5,
  "longBreakMinutes": 15,
  "pomodorosPerCycle": 4,
  "autoStartBreaks": false,
  "autoStartFocus": false,
  "showNotifications": true,
  "focusEndSound": "Glass",
  "breakEndSound": "Hero",
  "appearance": "system"
}
```
- `focusEndSound` / `breakEndSound`: ชื่อเสียงระบบ หรือ `null` = `None` (ไม่มี key = ค่าเริ่มต้น)
- `appearance`: `"system"` | `"light"` | `"dark"`

**`state.json`** (ตัวอย่าง: Focus 2/4 ที่เคย Start แล้ว เหลือ 14:02 จาก Focus 25 นาที)
```json
{
  "version": 1,
  "timer": {
    "phase": "focus",
    "displayNumber": 2,
    "pomodorosDone": 1,
    "pomodorosPerCycle": 4,
    "phaseLengthSeconds": 1500,
    "remainingSeconds": 842,
    "hasStarted": true
  },
  "floatingWindow": {
    "visible": true,
    "alwaysOnTop": true,
    "center": { "x": 720, "y": 844 }
  }
}
```
- `phase`: `"focus"` | `"shortBreak"` | `"longBreak"`
- `displayNumber` = `k` และ `pomodorosDone` = `done` ตามกติกา `k/N` ใน M2
- `pomodorosPerCycle` = N ของ **Cycle ปัจจุบัน** (ไม่ใช่ค่าใน Settings)
- `phaseLengthSeconds` = ความยาวเต็มของ Phase นี้ (ใช้วาดแถบ)
- `hasStarted` = เคย Start แล้ว (`false` → โหลดมาเป็น Ready, `true` → Paused)
- `center` = จุดกึ่งกลางแคปซูลตอนย่อ ในพิกัดรวมทุกจอของ AppKit `null` = ยังไม่เคยวาง (ใช้ตำแหน่งเริ่มต้น)
- `alwaysOnTop` อยู่ที่นี่ (ไม่อยู่ใน `settings.json`) เพราะเป็นสวิตช์ในเมนู ไม่อยู่ในหน้า Settings และ Restore Defaults ต้องไม่แตะ

**`history.json`**
```json
{
  "version": 1,
  "pomodoros": [
    { "end": "2026-10-14T17:10:00Z", "durationSeconds": 1500 },
    { "end": "2026-10-15T02:55:00Z", "durationSeconds": 1800 }
  ]
}
```

## P2. README

ที่มา: [02](issues/02-run-unsigned-app-gatekeeper.md) (ร่างจาก research บน branch `research/run-unsigned-app-gatekeeper` ปรับชื่อเป็น Pomodot แล้ว), [13](issues/13-data-storage.md), [15](issues/15-versioning-and-release.md)

- เขียน**ภาษาอังกฤษเป็นหลัก** + หัวข้อ**ภาษาไทย**ของขั้นตอน ติดตั้ง / อัปเดต / ถอนการติดตั้ง
- ลิงก์ดาวน์โหลด: `https://github.com/inwpasit619/pomodot/releases/latest`
- ต้องมี: ขั้นตอน Open Anyway, ติดตั้งด้วยการลากไป Applications (เลี่ยง App Translocation), ทางสำรอง `xattr -dr com.apple.quarantine`, อัปเดตด้วยการเอาไปทับ (ข้อมูลยังอยู่), ถอนการติดตั้งผ่าน Finder, ไม่รองรับ downgrade, หมายเหตุ "advanced" สำหรับคนที่อยาก build จาก source เอง (ต้องมี Command Line Tools, ใช้ `scripts/build-app.sh`)
- ใส่ screenshot จากการดาวน์โหลดจริง (ถ่ายตอนทดสอบ Open Anyway ใน M5) ได้ถ้ามี
- **ประโยคเรื่อง "อัปเดตแล้วต้องกด Open Anyway ซ้ำ" ให้เขียนตามผลทดสอบจริงใน M5** ร่างด้านล่างใส่ไว้เป็น `[…]` 

ข้อเท็จจริงที่ใช้ (จาก research): บน macOS 15, 26, 27 คลิกขวา › Open **ใช้ข้าม Gatekeeper ไม่ได้แล้ว** ต้องใช้ Open Anyway ใน Privacy & Security (ปุ่มขึ้นแค่ประมาณ 1 ชั่วโมงหลังโดนบล็อก) ทำครั้งเดียวต่อสำเนาที่ติดตั้ง, Safari แตก zip ให้เอง, ลากแอพไป Applications ด้วย Finder ทำให้ไม่โดน App Translocation, Homebrew ใช้ไม่ได้ (cask ที่ไม่ผ่าน Gatekeeper โดนปิดตั้งแต่ 2026-09-01)

### ร่างภาษาอังกฤษ

> **Installing Pomodot (about 1 minute, first time only)**
>
> 1. Download **Pomodot-X.Y.Z.zip** from the [latest release](https://github.com/inwpasit619/pomodot/releases/latest). Safari unzips it for you, and you'll see **Pomodot** in your Downloads folder.
> 2. Drag **Pomodot** into your **Applications** folder.
> 3. Open Applications and double-click **Pomodot**. A warning says macOS can't check it. This is expected, because the app isn't sold through Apple. Click **Done** (not "Move to Trash").
> 4. Within the next hour, open **System Settings** (Apple menu) and click **Privacy & Security** in the sidebar.
> 5. Scroll down to **Security**. You'll see a note that Pomodot was blocked. Click **Open Anyway**.
> 6. Type your Mac login password, then click **Open** when the warning appears one last time.
> 7. Done. From now on, Pomodot opens normally. Look for its icon in the menu bar.
>
> **If that doesn't work** (for example, if it says the app is "damaged"), open the **Terminal** app, paste this line, press Return, and then open Pomodot again:
> `xattr -dr com.apple.quarantine /Applications/Pomodot.app`
>
> **Updating:** Quit Pomodot from its menu, download the new zip, and drag the new **Pomodot** into Applications to replace the old one. Your History and Settings are kept. [ผลทดสอบ M5: ต้องทำข้อ 3–6 ซ้ำหรือไม่]
>
> Going back to an older version isn't supported.
>
> **Uninstalling:** (1) Quit Pomodot and drag it from Applications to the Trash. Deleting the app alone keeps your History. (2) To delete your data too: in Finder choose **Go › Go to Folder…**, enter `~/Library/Application Support/com.teppasit.pomodot`, and delete that folder. (3) Optional: remove Pomodot from **System Settings › Notifications**.

### ร่างภาษาไทย

> **ติดตั้ง Pomodot (ครั้งแรกใช้เวลาประมาณ 1 นาที)**
>
> 1. ดาวน์โหลด **Pomodot-X.Y.Z.zip** จาก[หน้า release ล่าสุด](https://github.com/inwpasit619/pomodot/releases/latest) Safari จะแตกไฟล์ให้เอง แล้วจะเห็น **Pomodot** อยู่ในโฟลเดอร์ Downloads
> 2. ลาก **Pomodot** ไปใส่ในโฟลเดอร์ **Applications**
> 3. เปิด Applications แล้วดับเบิลคลิก **Pomodot** จะมีคำเตือนว่า macOS ตรวจสอบแอพนี้ไม่ได้ ไม่ต้องตกใจ เป็นเพราะแอพนี้ไม่ได้ขายผ่าน Apple ให้กด **Done** (อย่ากด "Move to Trash")
> 4. ภายใน 1 ชั่วโมงหลังจากนั้น เปิด **System Settings** (จากเมนู Apple) แล้วคลิก **Privacy & Security** ที่แถบด้านซ้าย
> 5. เลื่อนลงไปที่หัวข้อ **Security** จะเห็นข้อความว่า Pomodot ถูกบล็อก ให้กด **Open Anyway**
> 6. ใส่รหัสผ่านที่ใช้ล็อกอินเครื่อง Mac แล้วกด **Open** ตอนที่คำเตือนขึ้นมาเป็นครั้งสุดท้าย
> 7. เสร็จแล้ว ต่อจากนี้เปิด Pomodot ได้ตามปกติ ไอคอนจะอยู่บน menu bar ด้านบนของจอ
>
> **ถ้ายังเปิดไม่ได้** (เช่น ขึ้นว่าแอพ "damaged") ให้เปิดแอพ **Terminal** วางคำสั่งข้างล่างนี้ กด Return แล้วลองเปิด Pomodot อีกครั้ง:
> `xattr -dr com.apple.quarantine /Applications/Pomodot.app`
>
> **อัปเดต:** Quit Pomodot จากเมนูของมัน ดาวน์โหลด zip ตัวใหม่ แล้วลาก **Pomodot** ตัวใหม่ไปทับตัวเดิมใน Applications History กับ Settings ยังอยู่ครบ [ผลทดสอบ M5: ต้องทำข้อ 3–6 ซ้ำหรือไม่]
>
> ไม่รองรับการย้อนกลับไปใช้เวอร์ชันเก่า
>
> **ถอนการติดตั้ง:** (1) Quit Pomodot แล้วลากออกจาก Applications ลงถังขยะ (ลบแอพอย่างเดียว History ยังอยู่) (2) ถ้าอยากลบข้อมูลด้วย: ใน Finder เลือก **Go › Go to Folder…** พิมพ์ `~/Library/Application Support/com.teppasit.pomodot` แล้วลบโฟลเดอร์นั้น (3) ไม่บังคับ: ลบรายการ Pomodot ใน **System Settings › Notifications**

## P3. แหล่งที่มา

| ตั๋ว | เรื่อง | ใช้ในหัวข้อ |
|---|---|---|
| [01](issues/01-build-app-without-xcode.md) | ใช้แค่ Command Line Tools สร้าง .app ที่ใช้งานได้จริงไหม | A4 |
| [02](issues/02-run-unsigned-app-gatekeeper.md) | เพื่อนเปิดแอพที่ไม่ได้ notarize จาก GitHub ได้ยังไง | M5, P2 |
| [03](issues/03-floating-window-apis.md) | หน้าต่างลอยบนสุด + menu bar ทำได้ด้วย API อะไร | A3, M1 |
| [04](issues/04-xcode-or-clt.md) | ติดตั้ง Xcode หรือใช้แค่ Command Line Tools | A3, A4 |
| [05](issues/05-minimum-macos.md) | ต้องรองรับ macOS ต่ำสุดเวอร์ชันไหน | A3, A4 |
| [06](issues/06-timer-rules.md) | กติกาของ timer | A6, M2 |
| [07](issues/07-menubar-vs-floating.md) | menu bar กับหน้าต่างลอย เกี่ยวกันยังไง | M1, M2, M5 |
| [08](issues/08-notification-and-sound.md) | แจ้งเตือนกับเสียงตอนหมดเวลา | M3, M5 |
| [09](issues/09-what-stats-mean.md) | สถิติ/ประวัติ นับอะไร แสดงยังไง | M4 |
| [10](issues/10-floating-window-look.md) | หน้าตาและตำแหน่งของหน้าต่างลอย | A10, M2, M5 |
| [11](issues/11-reinstall-clt-verify.md) | ติดตั้ง CLT ใหม่แล้วตรวจว่า build ผ่าน | A4 |
| [12](issues/12-code-structure-and-testing.md) | spec จะสั่ง agent ให้จัดโครงสร้างโค้ดและทดสอบยังไง | A5–A8 |
| [13](issues/13-data-storage.md) | เก็บข้อมูลของแอพไว้ที่ไหน รูปแบบอะไร | M2, M4, M5, P1 |
| [14](issues/14-app-name-and-icon.md) | ชื่อแอพ, bundle identifier และไอคอน | A3, A4, M1, M2 |
| [15](issues/15-versioning-and-release.md) | เลข version และขั้นตอนออก GitHub Release | A9, M5, P2 |

**ข้อที่ spec ทับของเก่า** (ตั๋วต้นทางยังเขียนแบบเดิม ให้เชื่อ spec):
- ชื่อแอพ `Pomodot` ทับ `Pomodoro` ทุกที่ (เมนู `Quit Pomodot`, ข้อความเตือนใน Settings, ร่าง README จาก research)
- ไอคอน menu bar ตอน Pause ไม่บอก Phase (ตั๋ว 14 ทับ 07)
- เมนูมี `About Pomodot` และ `Check for Updates…` ก่อน Quit (ตั๋ว 15 ทับ 07)
- universal build ในคำสั่งเดียว ไม่ใช้ `lipo` รวมเอง (ตั๋ว 11 ทับ 01)
- macOS ขั้นต่ำ 14 ไม่ใช่ 15 (ตั๋ว 05 ทับข้อแนะนำของ research ที่เป็นทาง SwiftUI ล้วน)
- ความยาวของ Pomodoro เก็บเป็นวินาที (ตั๋ว 13 ทับ "นาที" ในตั๋ว 09)
- executable target ชื่อ `Pomodot` (ตั๋ว 14 ทับชื่อ "App" ในตั๋ว 12)
