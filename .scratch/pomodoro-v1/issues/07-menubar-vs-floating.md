# menu bar กับหน้าต่างลอย เกี่ยวกันยังไง

Type: grilling
Label: wayfinder:grilling
Status: resolved
Assignee: teppasit
Map: [Map: Pomodoro ลอยบนจอ](../map.md)

## Question

ไอคอนบน menu bar กับหน้าต่างลอยแบ่งหน้าที่กันยังไง

- อันไหนเป็นตัวหลัก ซ่อนหน้าต่างลอยแล้วยังใช้งานผ่าน menu bar อย่างเดียวได้ไหม
- menu bar แสดงแค่ไอคอน หรือแสดงเวลานับถอยหลังด้วย
- คลิกที่ menu bar แล้วเกิดอะไรขึ้น (เปิดเมนู / popover / สลับซ่อน-แสดงหน้าต่างลอย)
- สวิตช์ always-on-top, หน้า Settings และสถิติ อยู่ตรงไหน
- มี Dock icon ไหม
- ปิดหน้าต่างลอยแล้ว = ซ่อนเฉยๆ หรือออกจากแอพ
- (ส่งต่อมาจากตั๋ว "กติกาของ timer") คำสั่ง **New Cycle** อยู่ในเมนูไหน และสวิตช์ auto-start 2 ตัว (Break / Focus) อยู่ใน Settings

## Answer

(ปิดเมื่อ 2026-10-15 คุยกับผู้ใช้ ศัพท์ **Floating Window** เพิ่มไว้ใน `CONTEXT.md`)

**รูปแบบของแอพ**
- เป็นแอพบน menu bar **ไม่มี Dock icon** (ไม่ขึ้นใน Cmd-Tab และไม่มีเมนูแอพด้านบนจอ)
- ข้อความในแอพใช้**ภาษาอังกฤษอย่างเดียว** ทั้งเมนู, Floating Window, Settings, สถิติ และ notification (หลายภาษาเป็น Out of scope ของ v1)

**ไอคอนบน menu bar**
- ไอคอนบอก Phase ปัจจุบัน (Focus / Break) และดูออกว่ากำลัง Pause
  - (แก้เมื่อ 2026-10-15 ในตั๋ว [ชื่อแอพ, bundle identifier และไอคอน](14-app-name-and-icon.md)) ตอน Pause ไอคอนเป็น `pause.circle` ทุก Phase และตัวเลขจางลง **ไอคอนไม่บอกว่าเป็น Phase ไหน** ดูได้จากเมนู ตอนเดินไอคอนยังบอก Phase (Focus = `timer`, Break = `cup.and.saucer.fill`)
- โชว์ `mm:ss` คู่กับไอคอน **เฉพาะตอนที่ timer เดินอยู่หรือ Pause** ตอนรอให้กด ▶︎ จะเหลือแค่ไอคอน **ไม่มีสวิตช์**ให้ปิดเวลา
- คลิกแล้วได้ **เมนู dropdown ธรรมดา** (ไม่ใช่ popover)

```
Today: 🍅 5                          ← สรุปวันนี้ (กดไม่ได้)
Focus 2/4 · ends 14:35               ← Phase ปัจจุบัน + Expected finish
Cycle ends 16:10                     ← Expected finish ของ Cycle
──────────────
⏸ Pause            (▶︎ Start / ▶︎ Resume ตามสถานะ)
Skip
Reset…
New Cycle…
──────────────
Hide Floating Window   (Show Floating Window ตอนซ่อนอยู่)
✓ Always on Top
──────────────
Statistics…
Settings…
──────────────
Quit Pomodoro
```

- โชว์ Expected finish ในเมนูด้วย เพราะตอนซ่อน Floating Window ไว้ เมนูเป็นที่เดียวที่ดูค่านี้ได้
- "…" ท้าย Reset / New Cycle ตามธรรมเนียม Mac ที่แปลว่าอาจมีกล่องถาม

**Floating Window**
- **ปิด = ซ่อน** timer และเวลาบน menu bar ยังเดินต่อ ซ่อน/แสดงได้ 2 ทาง: เมนู และปุ่มบน Floating Window (หน้าตาปุ่มไปตัดสินในตั๋ว "หน้าตาและตำแหน่งของหน้าต่างลอย") **ออกจากแอพได้ทางเดียวคือ Quit ในเมนู**
- จำไว้ว่าซ่อนหรือแสดงอยู่ข้ามการเปิดแอพใหม่ **เปิดแอพครั้งแรกสุดจะแสดงเสมอ**
- หมด Phase แล้ว **ไม่เด้งกลับมาเอง** ถึงจะซ่อนอยู่ การบอกว่าหมดเวลาเป็นหน้าที่ของ notification + เสียง
- **เปิดแอพซ้ำตอนที่รันอยู่แล้ว** (Finder / Spotlight) = แสดง Floating Window ไม่เปิดแอพตัวที่สอง เป็นทางกู้คืนเวลาไอคอนบน menu bar ถูกซ่อนหลังรอยบาก
- Floating Window ไม่มีปุ่ม Quit หรือเมนูคลิกขวาของตัวเอง

**Always on Top**
- สวิตช์อยู่ในเมนู menu bar **ที่เดียว** (ไม่อยู่ใน Settings และไม่มีปุ่มหมุดบน Floating Window) ค่าเริ่มต้นคือเปิด และแอพจำค่าที่เลือกไว้

**ถามยืนยันก่อน Reset และ New Cycle**
- ถามเฉพาะตอนที่มีของจะหายจริงๆ:
  - Reset: Phase เคยกด Start แล้ว (กำลังเดินหรือ Pause อยู่)
  - New Cycle: Cycle มี Pomodoro อย่างน้อย 1 อัน หรือ Phase ปัจจุบันเคยกด Start แล้ว
  - นอกจากนั้นทำเลยโดยไม่ถาม
- ไม่มีช่อง "ไม่ต้องถามอีก"
- กล่องยืนยันต้องขึ้นมาอยู่ด้านหน้าเสมอ (แอพที่ไม่มี Dock icon มักทำให้กล่องไปอยู่ด้านหลัง) และต้องอยู่ใน checklist ทดสอบด้วยมือ

**Settings และสถิติ**
- เปิดจากเมนู เป็นหน้าต่างปกติ (ไม่ลอยบนสุด มีปุ่มปิดสีแดง) **2 หน้าต่างแยกกัน** เนื้อหาของหน้าสถิติไปตัดสินในตั๋ว "สถิติ/ประวัติ นับอะไร แสดงยังไง"
- **Settings เป็นฟอร์มหน้าเดียวแบบมาตรฐานของ Mac:**

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
  (ตั๋ว "แจ้งเตือนกับเสียงตอนหมดเวลา ทำงานยังไง" มาเติม)

                      [Restore Defaults]
```

  - แต่ละ Phase ตั้งได้ 1–120 นาที (จำนวนเต็ม) และ Pomodoro ต่อ Cycle ตั้งได้ 1–10
  - เปลี่ยนแล้วมีผลทันที ไม่มีปุ่ม Save (จะมีผลกับ Phase ไหนเป็นไปตามตั๋ว "กติกาของ timer")
  - Restore Defaults จะกลับไปใช้ 25 / 5 / 15 / 4 และปิด auto-start ทั้งสองตัว
  - (เพิ่มภายหลังจากตั๋ว "หน้าตาและตำแหน่งของหน้าต่างลอย") Settings มีส่วน **Appearance** (`System` / `Light` / `Dark`) ต่อจาก Notifications & Sound และหน้าตาของฟอร์มนี้ดูที่ตั๋วนั้น

