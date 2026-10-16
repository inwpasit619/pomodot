# 07 — แอพที่ไม่ได้ notarize เปิดเองตอน login ได้ไหม

**Parent:** [map](../map.md)
**Type:** `wayfinder:research` (AFK)
**Assignee:** agent
**Blocked by:** —
**Status:** closed

## Question

Pomodot แจกเป็น `.zip` ที่ ad-hoc sign อย่างเดียว (ไม่ notarize, ไม่มี Developer ID) ผู้ใช้กด Open Anyway ครั้งแรก รองรับ macOS 14+ — ถ้าจะให้เปิดเองตอน login:

1. `SMAppService.mainApp.register()` ใช้กับแอพแบบนี้ได้ไหม มีเงื่อนไขอะไร (ต้องอยู่ใน `/Applications`? ต้องผ่าน Open Anyway ก่อน? ผู้ใช้ต้องอนุมัติใน System Settings › General › Login Items ไหม และเช็กสถานะ `.requiresApproval` / `.enabled` ได้ยังไง)
2. อัปเดตด้วยการลากแอพใหม่ไปทับ (ต้องกด Open Anyway ซ้ำ) แล้ว login item ยังอยู่ไหม ยังเปิดได้เองไหม หรือโดน Gatekeeper บล็อกเงียบๆ ตอน login
3. ลบแอพแล้ว login item ค้างไหม ผู้ใช้เอาออกเองได้ยังไง
4. ตอนแอพถูกเปิดโดย login รู้ได้ไหมว่ามาจาก login (เผื่อต้องทำต่างจากเปิดเอง) — ตอนนี้ตัดสินแล้วว่าแคปซูลโผล่เหมือนกัน จึงเป็นข้อมูลประกอบเท่านั้น
5. ทางเลือกอื่นถ้า SMAppService ใช้ไม่ได้ (เช่น ให้ผู้ใช้เพิ่มเองใน Login Items) และข้อเสีย

## Resolution

รายละเอียดเต็ม: branch `research/launch-at-login` (local, ห้าม push) ไฟล์ `docs/research/launch-at-login.md` ทดลองด้วย probe `com.teppasit.loginprobe` (ad-hoc sign ไม่มี Team ID เหมือน Pomodot) บน macOS 27.0.1 บัญชี admin — ลงทะเบียน 03:03–03:06 แล้ว**ยกเลิกแล้ว**

1. **`SMAppService.mainApp.register()` ใช้กับแอพ ad-hoc ได้** สถานะเป็น `.enabled` ทันที ผู้ใช้ไม่ต้องอนุมัติ ไม่ต้องอยู่ใน `/Applications` ขึ้นในรายการ Open at Login และระบบแจ้งเตือนหนึ่งครั้งว่าแอพจะเปิดตอน login [ยืนยัน] เงื่อนไขมีแค่ต้อง sign (ad-hoc พอ) [เอกสาร+ยืนยัน] ต้องผ่าน Open Anyway ก่อนเพราะแอพต้องรันอยู่ถึงจะเรียกได้ [อนุมาน] ระวัง: ไม่เคยลงทะเบียน = `.notFound` ไม่ใช่ `.notRegistered` [ยืนยัน]; `.requiresApproval` = ผู้ใช้ไปปิดเองใน System Settings [เอกสาร]
2. **อัปเดตทับแล้ว login item ยังอยู่และยัง `.enabled`** ไม่ต้องลงทะเบียนใหม่ [ยืนยัน] ตอน login ระบบเปิดแบบเดียวกับดับเบิลคลิก ถ้าตัวใหม่ยังไม่ผ่าน Open Anyway น่าจะเห็นกล่องเตือนของ Gatekeeper ไม่ใช่โดนบล็อกเงียบ [อนุมาน → ตรวจด้วยมือ]
3. **ลบแอพแล้ว login item ค้างอยู่ในรายการ** (ขึ้นสามเหลี่ยมเหลือง "moved or deleted") ตอน login ไม่เกิดอะไร ผู้ใช้ลบเองได้ที่ System Settings › General › Login Items & Extensions › เลือก › − [ยืนยัน+เอกสาร]
4. **รู้ได้ว่าเปิดจาก login** ผ่าน `keyAELaunchedAsLogInItem` ใน Apple event `oapp` อ่านได้ใน `applicationDidFinishLaunching` [เอกสาร+ยืนยันว่าเปิดเองไม่มี] แต่ยังไม่ยืนยันว่า mainApp ส่งมาจริง — ไม่จำเป็น เพราะแคปซูลโผล่เหมือนกัน
5. **ทางเลือกสำรอง:** ให้ผู้ใช้กด + เองใน Login Items (เปิดหน้าได้ด้วย `SMAppService.openSystemSettingsLoginItems()`) แอพรู้สถานะไม่ได้; LaunchAgent สับสนและเข้มเรื่อง quarantine; `SMLoginItemSetEnabled` เลิกใช้แล้ว

**คำแนะนำของผู้ช่วย (ให้ผู้ใช้ตัดสินในตั๋ว 08):** ใช้ `SMAppService.mainApp` ตรงๆ ไม่ต้องแก้ `build-app.sh`/`Info.plist`; เก็บสิ่งที่ผู้ใช้เลือกใน `settings.json`; ทุกครั้งที่เปิดแอพ ถ้าเลือกเปิดไว้แต่สถานะ `.notRegistered`/`.notFound` ให้ `register()` ใหม่ (รอผลตรวจด้วยมือ M3 ก่อนตัดสินกรณีผู้ใช้ไปลบเอง); `.requiresApproval` → ขึ้นข้อความพร้อมปุ่มเปิด Login Items; อ่านสถานะใหม่ทุกครั้งที่เปิดหน้า Settings; README บอกให้เปิดแอพเองหนึ่งครั้งหลังอัปเดต และปิดสวิตช์ก่อนลบแอพ

**ต้องตรวจด้วยมือ (logout/login หรือคลิกจริง):** login จริงแล้ว Pomodot เปิดเองไหม; อัปเดตทับแล้ว login โดยไม่เปิดก่อน เห็นกล่อง Gatekeeper หรือเงียบ; ลบ Pomodot ด้วย − ใน System Settings แล้วแอพอ่านได้สถานะอะไร; ลบแอพแล้วเห็นสามเหลี่ยมเหลือง; ทำซ้ำบน macOS 14/15 และบัญชีที่ไม่ใช่ admin
