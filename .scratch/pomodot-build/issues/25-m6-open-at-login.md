# 25 — M6 · Settings › General › `Open at login`

**Milestone:** M6 · branch `feature/m6-without-menu-bar`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M6 › Settings › `General` (`Open at login`), M6 › Test (Core) M6 (Settings: สถานะ login), M6 › Checklist ทดสอบด้วยมือ M6 › Settings › General, M5 › หน้าต่าง Settings และ A10

**What to build:** หน้าต่าง Settings มีหัวข้อใหม่ `General` อยู่บนสุด มีสวิตช์ `Open at login` ค่าเริ่มต้นปิด ที่แสดงตามสถานะจริงของ macOS เสมอ (ไม่เก็บในไฟล์) เปิดแล้ว Pomodot เปิดเองตอน login และแคปซูลโผล่ ถ้าระบบต้องให้อนุมัติ มีบรรทัดสีส้มพร้อมปุ่ม `Open Login Items…` และ `Restore Defaults` ไม่แตะสวิตช์นี้

**Blocked by:** 22 — M5 · ด่านปิด milestone + ออก `0.9.0` (ทำขนานกับใบ 23–24 ได้ แต่ทำบน branch เดียวกัน)

**Status:** ready-for-agent

- [ ] Core: แปลงสถานะ login (`enabled` / `notRegistered` / `notFound` / `requiresApproval`) เป็นสวิตช์เปิด/ปิด + มี/ไม่มีบรรทัดเตือน (Core ไม่ import ServiceManagement รับเป็น enum ของ Core เอง) test ผ่าน `/tdd`
- [ ] App: `SMAppService.mainApp` — อ่าน `status` ตอนเปิดหน้าต่าง Settings และตอนแอพกลับมา active, เปิด = `register()`, ปิด = `unregister()`, throw แล้วสวิตช์กลับตามสถานะจริง + log; ไม่ลงทะเบียนกลับเอง
- [ ] บรรทัดเตือนสีส้ม (`exclamationmark.triangle.fill`) ข้อความ `Pomodot needs your approval in System Settings to open at login.` + ปุ่ม `Open Login Items…` (`SMAppService.openSystemSettingsLoginItems()`) หน้าตาเหมือนบรรทัดเตือนสิทธิ์ notification
- [ ] หัวข้อ `General` อยู่เหนือ `Timer` สไตล์เดียวกับหัวข้ออื่น (ใบ 26 จะเพิ่ม `Show in Dock` ใต้สวิตช์นี้); `Restore Defaults` ไม่แตะ `Open at login`
- [ ] `docs/manual-test.md`: เพิ่มหมวด/ข้อตาม Checklist M6 › Settings › General ส่วน `Open at login` (รวมข้อ logout/login และเอาออกด้วยปุ่ม − ใน System Settings)
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน · agent เปิดแอพด้วย `open` แล้วถ่าย screenshot ของหน้าต่าง Settings (agent **ห้าม**เปิดสวิตช์ทิ้งไว้ในเครื่องผู้ใช้ ถ้าลองเปิดต้อง unregister คืนและบอกในรายงาน)
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
