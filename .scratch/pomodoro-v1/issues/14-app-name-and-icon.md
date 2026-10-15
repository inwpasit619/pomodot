# ชื่อแอพ, bundle identifier และไอคอน

Type: grilling
Label: wayfinder:grilling
Status: open
Map: [Map: Pomodoro ลอยบนจอ](../map.md)

## Question

milestone ที่ 1 ("โครงแอพ + หน้าต่างลอย" จากตั๋ว "spec จะสั่ง agent ให้จัดโครงสร้างโค้ดและทดสอบยังไง") build ไม่ได้ถ้ายังไม่มีชื่อ ต้องตัดสิน:

- **ชื่อแอพ** ที่เพื่อนเห็นใน Finder, banner แจ้งเตือน, Privacy & Security › Open Anyway และชื่อไฟล์ `.zip` (ตอนนี้ research กับตั๋วต่างๆ ใช้ `Pomodoro` เป็นชื่อชั่วคราว)
- **bundle identifier** (เช่น `com.<github-username>.<name>`) ตั้งแล้วห้ามเปลี่ยน เพราะ macOS ผูกสิทธิ์ notification และที่เก็บข้อมูลไว้กับค่านี้
- ชื่อ product/target ใน Swift package (agent เสนอให้ได้จากชื่อแอพ)
- **ไอคอนแอพ** หน้าตาแบบไหน ต้องให้เข้ากับ UI modern ที่ตัดสินไว้ในตั๋ว "หน้าตาและตำแหน่งของหน้าต่างลอย" (กระจก, มุมโค้ง, สีประจำ Phase) ใครเป็นคนทำ (agent วาดเป็น SVG แล้วแปลงเป็น `.icns` ด้วย `sips` + `iconutil` ตามตั๋ว "ใช้แค่ Command Line Tools สร้าง .app ที่ใช้งานได้จริงไหม" หรือผู้ใช้หามาเอง) และไอคอนบน menu bar ใช้ SF Symbol หรือวาดเอง

ข้อมูลที่มีแล้ว: ไม่ใช้ `.xcassets` ใช้ `.icns` ที่ใส่ไว้ใน `Contents/Resources`, ตอนเดินหรือ Pause menu bar โชว์เวลา (ตั๋ว "menu bar กับหน้าต่างลอย เกี่ยวกันยังไง")

(ส่งต่อมาจากตั๋ว "เก็บข้อมูลของแอพไว้ที่ไหน รูปแบบอะไร") bundle identifier เป็นชื่อโฟลเดอร์ข้อมูลด้วย คือ `~/Library/Application Support/<bundle-id>/` ถ้าเปลี่ยนค่านี้ทีหลัง History กับ Settings ของเพื่อนจะหายไป (ข้อมูลยังอยู่ในโฟลเดอร์เก่า แต่แอพจะไม่เห็น)
