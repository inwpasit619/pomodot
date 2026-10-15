# ชื่อแอพ, bundle identifier และไอคอน

Type: grilling
Label: wayfinder:grilling
Status: resolved
Assignee: teppasit
Map: [Map: Pomodoro ลอยบนจอ](../map.md)

## Question

milestone ที่ 1 ("โครงแอพ + หน้าต่างลอย" จากตั๋ว "spec จะสั่ง agent ให้จัดโครงสร้างโค้ดและทดสอบยังไง") build ไม่ได้ถ้ายังไม่มีชื่อ ต้องตัดสิน:

- **ชื่อแอพ** ที่เพื่อนเห็นใน Finder, banner แจ้งเตือน, Privacy & Security › Open Anyway และชื่อไฟล์ `.zip` (ตอนนี้ research กับตั๋วต่างๆ ใช้ `Pomodoro` เป็นชื่อชั่วคราว)
- **bundle identifier** (เช่น `com.<github-username>.<name>`) ตั้งแล้วห้ามเปลี่ยน เพราะ macOS ผูกสิทธิ์ notification และที่เก็บข้อมูลไว้กับค่านี้
- ชื่อ product/target ใน Swift package (agent เสนอให้ได้จากชื่อแอพ)
- **ไอคอนแอพ** หน้าตาแบบไหน ต้องให้เข้ากับ UI modern ที่ตัดสินไว้ในตั๋ว "หน้าตาและตำแหน่งของหน้าต่างลอย" (กระจก, มุมโค้ง, สีประจำ Phase) ใครเป็นคนทำ (agent วาดเป็น SVG แล้วแปลงเป็น `.icns` ด้วย `sips` + `iconutil` ตามตั๋ว "ใช้แค่ Command Line Tools สร้าง .app ที่ใช้งานได้จริงไหม" หรือผู้ใช้หามาเอง) และไอคอนบน menu bar ใช้ SF Symbol หรือวาดเอง

ข้อมูลที่มีแล้ว: ไม่ใช้ `.xcassets` ใช้ `.icns` ที่ใส่ไว้ใน `Contents/Resources`, ตอนเดินหรือ Pause menu bar โชว์เวลา (ตั๋ว "menu bar กับหน้าต่างลอย เกี่ยวกันยังไง")

(ส่งต่อมาจากตั๋ว "เก็บข้อมูลของแอพไว้ที่ไหน รูปแบบอะไร") bundle identifier เป็นชื่อโฟลเดอร์ข้อมูลด้วย คือ `~/Library/Application Support/<bundle-id>/` ถ้าเปลี่ยนค่านี้ทีหลัง History กับ Settings ของเพื่อนจะหายไป (ข้อมูลยังอยู่ในโฟลเดอร์เก่า แต่แอพจะไม่เห็น)

## Answer

(ปิดเมื่อ 2026-10-15 หน้าตัวอย่าง 2 หน้า คือไอคอนแอพ 10 แบบ (A–J) และไอคอนบน menu bar 4 แบบ + SF Symbols ตัวจริง เก็บไว้ที่ branch `prototype/app-icon` ไอคอนแอพตัวจริงอยู่ที่ [`assets/app-icon.svg`](../assets/app-icon.svg) และภาพที่ render แล้ว [`assets/app-icon-1024.png`](../assets/app-icon-1024.png))

**1. ชื่อ**
- ชื่อแอพคือ **Pomodot** (Pomodoro + dot มาจากจุดสีบนแคปซูล) สั้น และไม่ชนกับแอพที่ชื่อ "Pomodoro" ใน Notifications / Open Anyway / Spotlight
- ใช้ชื่อนี้ตรงกันทุกที่: product และ executable target ของ SwiftPM = `Pomodot`, `CFBundleExecutable` = `Pomodot`, `CFBundleName` / `CFBundleDisplayName` = `Pomodot`, bundle คือ `Pomodot.app` (ไม่ต้องสร้างชื่ออื่นอย่าง `PomodotApp`) ส่วน target Core / CoreTests ตั้งชื่อตามตั๋ว "spec จะสั่ง agent ให้จัดโครงสร้างโค้ดและทดสอบยังไง"
- ศัพท์ **Pomodoro** ใน `CONTEXT.md` ยังหมายถึง Focus ที่ทำครบเหมือนเดิม เปลี่ยนแค่หัวเรื่องของไฟล์เป็น Pomodot

**2. bundle identifier = `com.teppasit.pomodot`**
- ผู้ใช้เลือกเอง (ตัวเลือกที่ agent แนะนำคือ `io.github.teppasit-lovecode.pomodot`) **ตั้งแล้วห้ามเปลี่ยน** เพราะสิทธิ์ notification และโฟลเดอร์ข้อมูล `~/Library/Application Support/com.teppasit.pomodot/` ผูกกับค่านี้

**3. ไอคอนแอพ = แบบ A "แคปซูลบนพื้นแดง"**
- พื้นแดงมะเขือเทศไล่สี (#FF7B68 → #E0343A) มีแสงอ่อนๆ ที่มุมซ้ายบน + แคปซูลกระจกสีขาวตรงกลาง มีจุดแดง (#F0524F) อยู่ทางซ้าย และแถบเวลาที่เดินไปแล้ว 2/3 ไม่มีตัวเลข หน้าตาเหมือนแคปซูลตอนย่อของ Floating Window
- **agent เป็นคนทำ:** `AppIcon.svg` เป็นต้นฉบับ (ใช้ `assets/app-icon.svg` ได้เลย) มี script ใน repo ที่ render เป็น PNG ด้วย `sips` → ทำ `.iconset` ทุกขนาด (16–512 @1x/@2x) → `iconutil -c icns` → `Pomodot.icns` ใส่ไว้ใน `Contents/Resources` (`CFBundleIconFile`) ไม่ใช้ `.xcassets` (ทดสอบบนเครื่อง dev แล้วว่าใช้ได้ทุกขั้น)
- **กติกาของ SVG:**
  - วาดเต็มกริดไอคอนของ Apple: ผืน 1024×1024 ตัวไอคอน 824×824 วางที่ (100,100) มุมโค้ง rx ≈ 185
  - **ห้ามใช้ SVG filter** (เช่น `feDropShadow`, blur) เพราะ `sips` ไม่วาดให้ (ทดสอบแล้ว เงาหายไปเฉยๆ) ถ้าอยากได้เงาให้วาดเป็นรูปทรงโปร่งแสงแทน ส่วน linear/radial gradient ใช้ได้
- มีไอคอนแบบเดียว **ไม่ทำแบบ Dark / Tinted / Clear แยก** (ต้องใช้ Icon Composer ของ Xcode ซึ่ง v1 ไม่ได้ลง)
- ไอคอนที่ใช้จริงต่างจากหน้าตัวอย่างนิดหน่อย (เงาของแคปซูลเป็นรูปทรงธรรมดา ไม่ได้เบลอ) ผู้ใช้ต้องดูไอคอนจริงใน Finder แล้วบอกผ่านใน milestone 1

**4. ไอคอนบน menu bar = SF Symbols**
- เป็น**ไอคอนลายเส้นสีเดียว (template image) ที่เปลี่ยนสีตาม menu bar** เหมือนไอคอน Wi‑Fi หรือแบตเตอรี่ **ไม่ใช่ emoji** และไม่มีสี
- Focus กำลังเดิน = `timer` + `mm:ss`
- Short Break และ Long Break กำลังเดิน = `cup.and.saucer.fill` (ใช้ตัวเดียวกันทั้ง 2 Break) + `mm:ss`
- **Pause (ทุก Phase) = `pause.circle` + `mm:ss` สีจางลง** ตอน Pause ไอคอนจะไม่บอกว่าเป็น Phase ไหน (ดูได้จากเมนู dropdown) ข้อนี้**แก้**ข้อที่ตกลงไว้ในตั๋ว "menu bar กับหน้าต่างลอย เกี่ยวกันยังไง" ที่บอกว่าไอคอนต้องบอกทั้ง Phase และการ Pause ผู้ใช้เลือกแบบนี้เองหลังจากเห็นทั้ง 2 แบบ
- รอกด ▶︎ = ไอคอนของ Phase ที่รออยู่ (`timer` หรือ `cup.and.saucer.fill`) และไม่มีเวลา (agent ตัดสินเอง)
- ทั้ง 3 ตัวมีมาตั้งแต่ก่อน macOS 14 แต่ตอน build ให้ agent เช็กว่าชื่อทุกตัวโหลดได้จริง (`NSImage(systemSymbolName:)` ต้องไม่ได้ nil) ถ้าไม่ได้ให้หยุดแล้วรายงาน ห้ามเปลี่ยนไปใช้ตัวอื่นเอง

**5. Checklist ทดสอบด้วยมือ** (`docs/manual-test.md` แบบ Given/When/Then)
- (milestone 1) เปิด Finder › Applications → เห็นไอคอนแบบ A ชื่อ `Pomodot` ผู้ใช้บอกผ่านเรื่องหน้าตา
- (milestone 2) menu bar ทั้งแบบสีอ่อนและสีเข้ม: Focus เดิน → `timer` + เวลา, Break เดิน → ถ้วยกาแฟ + เวลา, Pause → `pause.circle` + เวลาจาง, รอกด ▶︎ → ไอคอนของ Phase ที่รอ ไม่มีเวลา ไอคอนเปลี่ยนสีตาม menu bar
- (milestone 3) banner แจ้งเตือนขึ้นไอคอนแบบ A และชื่อ `Pomodot`, System Settings › Notifications มีรายการ `Pomodot` พร้อมไอคอน
- (milestone 5) เครื่องเพื่อนตอนกด Open Anyway เห็นชื่อ `Pomodot`

**ส่งต่อ**
- ตั๋ว "เลข version และขั้นตอนออก GitHub Release": ชื่อไฟล์ `.zip` ขึ้นต้นด้วย `Pomodot` และ bundle identifier คือ `com.teppasit.pomodot` (ห้ามเปลี่ยน ถ้าเปลี่ยนจะอัปเดตทับแล้วข้อมูลหาย)
- ตั๋ว "menu bar กับหน้าต่างลอย เกี่ยวกันยังไง": เพิ่มหมายเหตุเรื่องไอคอนตอน Pause แล้ว
