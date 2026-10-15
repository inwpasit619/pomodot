# เลข version และขั้นตอนออก GitHub Release

Type: grilling
Label: wayfinder:grilling
Status: open
Map: [Map: Pomodoro ลอยบนจอ](../map.md)
Blocked by: 14

## Question

milestone ที่ 5 ("Settings + Appearance + แจกจ่าย") ต้องมีขั้นตอนออกเวอร์ชันที่ agent ทำได้ครบ ส่วนผู้ใช้กดเองให้น้อยที่สุด (agent เสนอทางที่แนะนำ + trade-off เป็นภาษาคน แล้วให้ผู้ใช้อนุมัติ)

- รูปแบบเลข version (เช่น `1.0.0`) ใส่ไว้ตรงไหน (`CFBundleShortVersionString` / `CFBundleVersion` ใน Info.plist) และใครเป็นคนเพิ่มเลข
- ออก GitHub Release ยังไง: agent ใช้ `gh release create` จากเครื่อง dev หรือใช้ GitHub Actions build บน runner ของ macOS (ถ้าใช้ Actions ต้องเช็กว่า runner ทำ universal build + ad-hoc sign ได้เหมือนเครื่อง dev) มี tag ไหม และ release notes ภาษาอะไร
- ชื่อไฟล์ `.zip` สร้างยังไง (`ditto -c -k --keepParent` เพื่อให้ signature ไม่เสีย) และตรวจอะไรก่อนอัปโหลด (`codesign -v --strict --deep`)
- อัปเดต: เพื่อนรู้ได้ยังไงว่ามีเวอร์ชันใหม่ (v1 ไม่มีระบบ auto-update หรือมีแค่ลิงก์ในเมนู) แล้วติดตั้งทับยังไงให้ข้อมูลเดิมยังอยู่ research ในตั๋ว "เพื่อนเปิดแอพที่ไม่ได้ notarize จาก GitHub ได้ยังไง" **คาดว่า**ทุกครั้งที่อัปเดตต้องกด Open Anyway ใหม่ (ยังไม่ได้ทดสอบ) และร่างขั้นตอนติดตั้งใน README ไว้แล้ว ตัดสินว่าจะยอมรับข้อนี้ไปเลย หรือต้องทดสอบให้รู้แน่ก่อน

(ส่งต่อมาจากตั๋ว "เก็บข้อมูลของแอพไว้ที่ไหน รูปแบบอะไร") อัปเดตด้วยการเอาแอพใหม่ไปทับ **ข้อมูลยังอยู่** (เก็บแยกไว้ใน `~/Library/Application Support/<bundle-id>/`) ตราบใดที่ bundle identifier ไม่เปลี่ยน ไม่รองรับ downgrade และ README มีหัวข้อ "ถอนการติดตั้ง" ผ่าน Finder ที่ต้องรวมไว้ในส่วนแจกจ่าย

(ส่งต่อมาจากตั๋ว "ชื่อแอพ, bundle identifier และไอคอน") ชื่อแอพคือ **Pomodot** (`Pomodot.app`) ชื่อไฟล์ `.zip` ต้องขึ้นต้นด้วย `Pomodot` ส่วน bundle identifier คือ **`com.teppasit.pomodot`** ซึ่งห้ามเปลี่ยน ถ้าเปลี่ยน เพื่อนที่อัปเดตทับจะเห็นเป็นแอพใหม่ ข้อมูลกับสิทธิ์ notification จะหาย ไอคอน `Pomodot.icns` สร้างด้วย script จาก `AppIcon.svg` ขั้นตอนออก release ต้องเรียก script นี้ด้วย (หรือใช้ไฟล์ที่ commit ไว้)
