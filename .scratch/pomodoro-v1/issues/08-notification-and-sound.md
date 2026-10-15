# แจ้งเตือนกับเสียงตอนหมดเวลา ทำงานยังไง

Type: grilling
Label: wayfinder:grilling
Status: resolved
Assignee: teppasit
Map: [Map: Pomodoro ลอยบนจอ](../map.md)

## Question

ตอนแต่ละช่วงจบ (focus → break, break → focus) ควรเกิดอะไรขึ้น

- ใช้ notification ของระบบ (banner ที่มุมขวาบน), หรือให้หน้าต่างลอยเปลี่ยนสี/เด้งเอง, หรือทั้งสองอย่าง
- ใช้เสียงอะไร (เสียงระบบของ macOS หรือไฟล์เสียงในแอพ) ดังครั้งเดียวหรือดังซ้ำจนกว่าจะกดรับ
- ปิดเสียง / ปิดแจ้งเตือนใน Settings ได้ไหม
- ถ้าผู้ใช้ไม่อนุญาต notification ตอนแอพขอสิทธิ์ แอพควรทำยังไง
- มีเสียงติ๊กๆ ระหว่าง focus ไหม (ค่าเริ่มต้นคือไม่มี)

## Answer

(ปิดเมื่อ 2026-10-15 คุยกับผู้ใช้ ศัพท์อยู่ใน `CONTEXT.md`)

**ช่องทาง**
- เมื่อ Phase **หมดเวลาเอง** แอพแจ้ง 2 ทาง: **banner notification ของ macOS + เสียง**
- banner ต้อง**ขึ้นทุกครั้ง** ถึงตอนนั้นแอพจะเป็นแอพที่ใช้อยู่ก็ตาม (ค่าเริ่มต้นของ macOS จะไม่แสดง banner ในกรณีนี้ spec ต้องสั่งให้แสดง)
- Floating Window แค่เปลี่ยนไปแสดง Phase ถัดไป ไม่กะพริบหรือเปลี่ยนสีเพื่อแจ้งเตือน (ส่วน animation เล็กๆ ตอนเปลี่ยน Phase ไปตัดสินในตั๋ว "หน้าตาและตำแหน่งของหน้าต่างลอย")
- **มีแจ้งเตือนเฉพาะตอนหมดเวลาเอง** ถ้า Skip / Reset / New Cycle หรือ auto-pause เพราะเครื่อง sleep จะไม่มีทั้ง banner และเสียง

**เสียง**
- ใช้**เสียงระบบของ macOS** ดัง**ครั้งเดียว** ไม่ดังซ้ำ
- **แอพเป็นคนเล่นเสียงเอง** ไม่ฝากไปกับ notification ทำให้เสียงยังดังถึงจะปิด notification, ไม่ได้ให้สิทธิ์ หรือเปิด Focus / Do Not Disturb ของ macOS อยู่ เทียบได้กับนาฬิกาปลุกที่เราตั้งเอง ข้อนี้ต้องเขียนไว้ใน spec จะได้ไม่มีใครเข้าใจว่าเป็นบั๊ก ส่วน banner เป็นไปตามกติกาของ macOS (โดนซ่อนตอน Do Not Disturb)
- มีเสียง 2 ช่อง ค่าเริ่มต้นคือ จบ Focus = **Glass** และจบ Break (Short และ Long) = **Hero** ผู้ใช้เลือกเปลี่ยนเองได้
- ไม่มีเสียงติ๊กระหว่าง Focus

**Settings ส่วน Notifications & Sound** (เติมช่องที่ตั๋ว "menu bar กับหน้าต่างลอย เกี่ยวกันยังไง" เว้นไว้)

```
Notifications & Sound
  [✓] Show notifications
      ⚠️ Notifications are turned off for Pomodoro in System Settings.
         [Open System Settings…]          ← ขึ้นเฉพาะตอนระบบปิดสิทธิ์ไว้
      End of Focus sound   [ Glass ▾ ]
      End of Break sound   [ Hero  ▾ ]
```

- dropdown มีเสียงระบบทุกตัวของ macOS และมี `None` อยู่บนสุด **เลือกแล้วเล่นให้ฟังทันที** ไม่มีปุ่ม ▶︎ แยก
- ไม่มีสวิตช์ปิดเสียงทั้งหมด (อยากเงียบก็เลือก `None`) และไม่มีปุ่มปรับความดัง ใช้ความดังของเครื่อง
- `Show notifications` ค่าเริ่มต้นคือเปิด ถ้าปิดไว้จะเหลือแค่เสียง
- Restore Defaults: เปิด `Show notifications` และตั้งเสียงกลับเป็น Glass / Hero
- `[Open System Settings…]` เปิดหน้า Notifications ของ System Settings

**ขอสิทธิ์ notification**
- ขอตอน**กด ▶︎ Start ครั้งแรกสุด** ไม่ขอตอนเปิดแอพ timer เริ่มเดินทันทีโดยไม่รอคำตอบ
- ใช้กล่อง Allow / Don't Allow แบบปกติ **ไม่ใช้ provisional** (โหมดนั้นไม่ขึ้น banner)
- ถ้ากด Don't Allow: แอพใช้งานได้ตามปกติ เสียงยังดัง **ไม่มี popup ถามซ้ำ** และมีบรรทัดเตือนใน Settings ตามรูปด้านบน
- ถ้าผู้ใช้ปิด `Show notifications` ในแอพเอง จะไม่ขอสิทธิ์และไม่โชว์บรรทัดเตือน

**ข้อความใน banner** (UI ภาษาอังกฤษ เปลี่ยนคำตามว่า Phase ถัดไปเริ่มเองหรือรอให้กด ▶︎ ส่วนตัวเลขเป็นค่าจริงจาก Settings และ Cycle)

| เหตุการณ์ | หัวข้อ | เนื้อความ (รอกด ▶︎) | เนื้อความ (เริ่มเอง) |
|---|---|---|---|
| Focus จบ → Short Break | `Focus complete 🍅 2/4` | `Time for a 5-minute Short Break.` | `5-minute Short Break started.` |
| Focus จบ → Long Break | `Cycle complete 🍅 4/4` | `Time for a 15-minute Long Break.` | `15-minute Long Break started.` |
| Short Break จบ → Focus | `Break over` | `Time for Focus 3/4.` | `Focus 3/4 started.` |
| Long Break จบ | `Long Break over` | `Ready for a new Cycle.` | (ไม่มีกรณีนี้ เพราะหยุดรอเสมอ) |

**พฤติกรรมของ banner**
- banner ใหม่**ทับอันเก่า** ใน Notification Center จะเหลือแค่อันล่าสุดอันเดียว
- **คลิก banner = แสดง Floating Window** (ถ้าซ่อนอยู่) ข้อนี้ไม่ขัดกับกติกา "หมด Phase แล้วไม่เด้งกลับมาเอง" เพราะผู้ใช้เป็นคนคลิกเอง
- ไม่มีปุ่ม action บน banner ใน v1

**ส่งต่อให้ตั๋วอื่น**
- ตั๋ว "spec จะสั่ง agent ให้จัดโครงสร้างโค้ดและทดสอบยังไง": เพิ่มเรื่องที่ต้องทดสอบ (อยู่ในตั๋วนั้นแล้ว)
- ตั๋ว "หน้าตาและตำแหน่งของหน้าต่างลอย": จะมี animation เล็กๆ ตอนเปลี่ยน Phase ไหม และหน้าตาของส่วน Notifications & Sound ให้เข้ากับสไตล์ modern
