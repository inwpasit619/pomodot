# เพื่อนเปิดแอพที่ไม่ได้ notarize จาก GitHub ได้ยังไง

Type: research
Label: wayfinder:research
Status: resolved
Map: [Map: Pomodoro ลอยบนจอ](../map.md)
Findings: branch `research/run-unsigned-app-gatekeeper` → `docs/research/run-unsigned-app-gatekeeper.md`

## Question

แอพที่ไม่ได้ sign ด้วย Developer ID และไม่ได้ notarize (มีแค่ ad-hoc signature หรือไม่ sign เลย) ถ้าดาวน์โหลดจาก GitHub Release ผ่าน browser จะเจออะไรบน macOS 15 Sequoia, 26 และ 27 บ้าง

- Gatekeeper/quarantine ขวางยังไง ขั้นตอนที่เพื่อนต้องทำจริงๆ บนแต่ละเวอร์ชันคืออะไร (เช่น ปุ่ม "Open Anyway" ใน System Settings › Privacy & Security, `xattr -d com.apple.quarantine`) ใน Sequoia เอา right-click › Open ออกไปแล้วหรือยัง
- ad-hoc signing ช่วยหรือทำให้แย่ลงไหม (Apple Silicon บังคับให้มี signature อย่างน้อยแบบ ad-hoc)
- zip กับ dmg มีผลต่อ quarantine/translocation ต่างกันไหม
- ทางอื่นที่ไม่ต้องจ่ายเงิน เช่น Homebrew cask (ยังรับแอพที่ไม่ notarize ไหม), ให้เพื่อน build จาก source เอง

สรุปเป็นทางที่แนะนำ + ขั้นตอนติดตั้งที่ง่ายที่สุดสำหรับเพื่อนที่ไม่ใช่สาย dev

## Answer

(ปิดโดย research subagent รายละเอียดและแหล่งอ้างอิงดูที่ branch `research/run-unsigned-app-gatekeeper` ไฟล์ `docs/research/run-unsigned-app-gatekeeper.md` commit e595471)

- **แจกได้โดยไม่ต้องจ่ายเงิน** บน macOS 15, 26 และ 27 เพื่อนเปิดแอพครั้งแรกโดย: ดับเบิลคลิก › กด Done › ไปที่ System Settings › Privacy & Security › **Open Anyway** (ปุ่มนี้ขึ้นแค่ประมาณ 1 ชั่วโมงหลังจากโดนบล็อก) › ใส่รหัสผ่าน › Open
- **ตั้งแต่ Sequoia 15 คลิกขวา › Open ใช้ข้ามไม่ได้แล้ว** ส่วน macOS 26/27 ไม่เจอว่ามีอะไรเปลี่ยนให้ผู้ใช้เห็น แต่ยังไม่ได้ลองดูหน้าต่างแจ้งเตือนจริงบน 26/27
- **ต้อง ad-hoc sign ทั้ง bundle** (`codesign --force --sign - <App>.app` แล้วตรวจด้วย `codesign -v --strict --deep`) ถ้าแค่เอา executable ที่ linker sign มาใส่ใน `.app` ที่ประกอบเอง จะ verify ไม่ผ่าน (ทดลองแล้วบน 27.0.1) และน่าจะเจอข้อความ "damaged" แบบที่ไม่มีปุ่ม Open Anyway ให้กด
- **แจกเป็น `.zip`** (แนะนำให้สร้างด้วย `ditto`) ไม่ใช้ `.dmg` ให้เพื่อนลากแอพไปไว้ใน Applications เพื่อเลี่ยง App Translocation ทางสำรองคือคำสั่ง `xattr -dr com.apple.quarantine`
- **Homebrew ใช้ไม่ได้แล้ว** cask ที่ไม่ผ่าน Gatekeeper โดนปิดตั้งแต่ 2026-09-01 ส่วนให้เพื่อน build จาก source เองใส่ไว้เป็นหมายเหตุ "advanced" ใน README เท่านั้น
- มีขั้นตอนติดตั้งทั้งภาษาไทยและอังกฤษเตรียมไว้ใส่ README แล้ว
- ส่วนที่เป็นการอนุมานเอง ยังไม่มีแหล่งยืนยัน: ทุกครั้งที่อัปเดตแอพ เพื่อนอาจต้องกด Open Anyway ใหม่
