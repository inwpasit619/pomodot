# Pomodot — Checklist ทดสอบด้วยมือ

ทำตามทีละข้อ ผ่านแล้วติ๊ก `[x]` ป้ายท้ายข้อบอกว่ามาจาก milestone ไหน

## Floating Window

## Menu bar

- [ ] (M1) **Given** เปิด Pomodot อยู่ **When** ดูที่ Dock และกด Cmd-Tab ค้างไว้ **Then** ไม่มีไอคอน Pomodot ทั้งใน Dock และในแถบ Cmd-Tab และแถบเมนูด้านบนจอไม่ขึ้นชื่อ Pomodot
- [ ] (M1) **Given** เปิด Pomodot อยู่ **When** ดูที่ menu bar ด้านขวาบน **Then** มีไอคอนนาฬิกาจับเวลา (ยังไม่มีตัวเลขเวลา) ถ้ามองไม่เห็นเพราะไอคอนเยอะจนโดนรอยบากบัง ให้ปิดแอพอื่นบน menu bar บางตัวก่อน
- [ ] (M1) **Given** เห็นไอคอนนาฬิกาบน menu bar **When** คลิกไอคอน **Then** มีเมนูหล่นลงมาและมีคำสั่ง `Quit Pomodot`
- [ ] (M1) **Given** เปิดเมนูของ Pomodot อยู่ **When** กด `Quit Pomodot` **Then** ไอคอนนาฬิกาหายไปจาก menu bar และแอพปิดไป

## Notification & Sound

## Statistics

## Appearance

- [ ] (M1) **Given** เปิด Finder ไปที่โฟลเดอร์ `dist` ในโปรเจกต์ **When** ดูไฟล์ `Pomodot` **Then** ชื่อแสดงเป็น `Pomodot` และไอคอนเป็นแคปซูลสีขาวบนพื้นสีแดงมะเขือเทศ (เงาเป็นรูปทรงธรรมดา ไม่เบลอ) **บอกว่าหน้าตาไอคอนผ่านหรือไม่**

## ติดตั้งบนเครื่องเพื่อน
