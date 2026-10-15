# เพื่อนเปิดแอพที่ไม่ได้ notarize จาก GitHub ได้ยังไง

Type: research
Label: wayfinder:research
Status: open
Map: [Map: Pomodoro ลอยบนจอ](../map.md)
Findings: branch `research/run-unsigned-app-gatekeeper` → `docs/research/run-unsigned-app-gatekeeper.md`

## Question

แอพที่ไม่ได้ sign ด้วย Developer ID และไม่ได้ notarize (มีแค่ ad-hoc signature หรือไม่ sign เลย) ถ้าดาวน์โหลดจาก GitHub Release ผ่าน browser จะเจออะไรบน macOS 15 Sequoia, 26 และ 27 บ้าง

- Gatekeeper/quarantine ขวางยังไง ขั้นตอนที่เพื่อนต้องทำจริงๆ บนแต่ละเวอร์ชันคืออะไร (เช่น ปุ่ม "Open Anyway" ใน System Settings › Privacy & Security, `xattr -d com.apple.quarantine`) ใน Sequoia เอา right-click › Open ออกไปแล้วหรือยัง
- ad-hoc signing ช่วยหรือทำให้แย่ลงไหม (Apple Silicon บังคับให้มี signature อย่างน้อยแบบ ad-hoc)
- zip กับ dmg มีผลต่อ quarantine/translocation ต่างกันไหม
- ทางอื่นที่ไม่ต้องจ่ายเงิน เช่น Homebrew cask (ยังรับแอพที่ไม่ notarize ไหม), ให้เพื่อน build จาก source เอง

สรุปเป็นทางที่แนะนำ + ขั้นตอนติดตั้งที่ง่ายที่สุดสำหรับเพื่อนที่ไม่ใช่สาย dev
