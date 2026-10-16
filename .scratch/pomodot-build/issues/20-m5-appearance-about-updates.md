# 20 — M5 · Appearance + About + Check for Updates

**Milestone:** M5 · branch `feature/m5-settings-release`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M5 › หน้าต่าง Settings (Appearance), M5 › About / Check for Updates, M2 › Menu bar › เมนู dropdown และ A10

**What to build:** หน้า Settings มีส่วน **Appearance** เป็นตัวเลือก `System | Light | Dark` (ค่าเริ่มต้น System) เลือกแล้วทุกหน้าต่างรวมถึงแคปซูลเปลี่ยนตามทันที ถ้าเลือก System แล้วเครื่องสลับโหมด แอพก็เปลี่ยนตามทันที ถ้าเลือก Light หรือ Dark แอพจะไม่สนโหมดของเครื่อง ในเมนูมี `About Pomodot` ที่เปิดหน้าต่าง About มาตรฐานของ macOS ซึ่งโชว์ไอคอน ชื่อ และ `0.9.0 (build N)` กับ `Check for Updates…` ที่เปิดหน้า Releases ของ `inwpasit619/pomodot` ใน browser ใบนี้ทำให้เมนูครบตามโครงเมนูสุดท้าย

**Blocked by:** 19 — Settings ส่วน Notifications & Sound

**Status:** ready-for-agent

- [ ] Appearance ใช้ `NSApp.appearance` และบันทึกลง `settings.json`
- [ ] About ใช้ `NSApp.orderFrontStandardAboutPanel` และ version มาจาก `Info.plist` ที่ script ใส่ให้
- [ ] `Check for Updates…` เปิด `https://github.com/inwpasit619/pomodot/releases` (เป็นค่าคงที่ใน App ไม่ต้องมี test) แอพไม่ต่อเน็ตเอง
- [ ] เมนูเรียงตรงตามโครงเมนูสุดท้ายในหัวข้อ M2 › Menu bar ทุกบรรทัด
- [ ] เพิ่มหมวด Appearance และข้อเมนูใน `docs/manual-test.md`: System แล้วสลับโหมดเครื่อง → ทุกหน้าต่างรวมแคปซูลเปลี่ยนตามทันที, Light / Dark → ไม่สนโหมดเครื่อง, About เห็นไอคอน ชื่อ และ `0.9.0`, Check for Updates… เปิดหน้า Releases
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot ทั้ง Light และ Dark
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
