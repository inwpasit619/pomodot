# 27 — M6 · README สำหรับ 0.10.0

**Milestone:** M6 · branch `feature/m6-without-menu-bar`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) ภาคผนวก P2 (ข้อ "M6 (0.10.0) เพิ่ม") และ M6 › Settings › `General`

**What to build:** `README.md` บอกเพื่อนครบทั้งภาษาอังกฤษและหัวข้อภาษาไทย: ปุ่ม `…` บนการ์ด / คลิกขวาที่แคปซูลเปิดคำสั่งทั้งหมด, ซ่อนแคปซูลแล้วเอากลับด้วยการเปิด Pomodot ซ้ำหรือคลิกไอคอนบน Dock, สวิตช์ `Open at login` และ `Show in Dock`, ส่วน Updating บอกให้เปิด Pomodot เองหนึ่งครั้ง (Open Anyway) หลังลากทับก่อนรีสตาร์ทถ้าเปิด `Open at login` ไว้, ส่วน Uninstalling บอกให้ปิด `Open at login` ก่อนลบ หรือเอารายการที่ค้างออกด้วยปุ่ม − ใน System Settings › General › Login Items & Extensions

**Blocked by:** 24, 25, 26 (เขียนตามพฤติกรรมจริงที่ทำเสร็จแล้ว)

**Status:** ready-for-agent

- [ ] ภาษาอังกฤษเป็นหลัก หัวข้อภาษาไทยของขั้นตอนติดตั้ง / อัปเดต / ถอนการติดตั้งอัปเดตตาม (ภาษาคน ประโยคสั้น เหมือน README เดิม)
- [ ] ชื่อปุ่ม/สวิตช์ตรงกับที่แอพแสดงจริงทุกตัว (`Hide Floating Window`, `Open at login`, `Show in Dock`, `Open Login Items…`)
- [ ] ไม่มีขั้นตอนที่ต้องใช้ Terminal เพิ่มจากเดิม
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
