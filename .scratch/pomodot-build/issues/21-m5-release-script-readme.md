# 21 — M5 · `release.sh` + README + ทดสอบ Open Anyway ตอนอัปเดต

**Milestone:** M5 · branch `feature/m5-settings-release`
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ M5 › แจกจ่าย (เลข version, `scripts/release.sh`, ทดสอบ Open Anyway ตอนอัปเดต, ข้อมูลตอนลบ/อัปเดตแอพ) และภาคผนวก P2

**What to build:** มี `scripts/release.sh` ที่ใช้ `build-app.sh` ตัวเดิม แล้วต่อด้วยขั้นตรวจทุกขั้นตาม spec ข้อไหนไม่ผ่านจะหยุดทันทีโดยไม่อัปโหลด มี `README.md` ภาษาอังกฤษเป็นหลัก มีหัวข้อภาษาไทยของขั้นตอนติดตั้ง / อัปเดต / ถอนการติดตั้ง ตามร่างใน P2 และรู้ผลจริงแล้วว่าการอัปเดตทับต้องกด Open Anyway ซ้ำหรือไม่ แล้วเขียนผลนั้นลง README ใบนี้**ยังไม่ tag และยังไม่อัปโหลด** อะไรขึ้น GitHub

**Blocked by:** 20 — Appearance + About + Check for Updates

**Status:** ready-for-agent (มีจุดหยุดรอผู้ใช้ 🛑)

- [ ] `release.sh` ทำขั้น 1–6 ตาม spec: ตรวจ branch, งานค้าง และ tag ทั้งในเครื่องและบน GitHub, เงื่อนไข "เสร็จ" 7 ข้อ, `lipo -archs` ต้องมีทั้ง `arm64` และ `x86_64`, `codesign --verify --strict --deep`, zip ด้วย `ditto -c -k --keepParent` แล้วแตกด้วย `ditto -x -k` และ verify ซ้ำ **ไม่ใช้ `spctl --assess` เป็นตัวตัดสิน**
- [ ] ขั้น 7 (โชว์ release notes → รอผู้ใช้อนุมัติ → tag → push → `gh release create` โดยไม่ใส่ `--prerelease` → `gh release download` แล้วเทียบ `shasum -a 256`) มีอยู่ใน script แต่ใบนี้ยังไม่รันจริง
- [ ] ทดลองให้เห็นว่า script หยุดเองเมื่อไม่ได้อยู่บน `main` และขั้นตรวจ 3–5 ผ่านกับ build จริง
- [ ] agent ทำ build ทดสอบ 2 ตัวที่ `CFBundleVersion` ต่างกัน zip แล้วใส่ quarantine ด้วย `xattr -w com.apple.quarantine …` ตาม spec
- [ ] 🛑 ให้ผู้ใช้แตกไฟล์ด้วย Finder, ติดตั้งตัวแรก → กด Open Anyway → เอาตัวที่สองไปทับ → ดูว่า macOS บล็อกอีกไหม แล้วบันทึกผลไว้สำหรับรายงาน M5
- [ ] README ครบตามรายการใน P2 และแทนที่ `[ผลทดสอบ M5: …]` ทั้งภาษาอังกฤษและภาษาไทยด้วยผลจริง
- [ ] เพิ่มหมวด ติดตั้งบนเครื่องเพื่อน ใน `docs/manual-test.md`: อัปเดตทับแล้ว History กับ Settings ยังอยู่, ลบแอพแล้วลงใหม่ History ยังอยู่, ลบโฟลเดอร์ข้อมูลตาม README แล้วเริ่มใหม่สะอาด, เครื่องเพื่อนดาวน์โหลดจาก `releases/latest` → ลากไป Applications → Open Anyway (เห็นชื่อ `Pomodot`) → ใช้งานได้
- [ ] ข้อตรวจประจำ: `swift test` ผ่าน · build universal ผ่านโดยไม่มี warning ใหม่ · `scripts/build-app.sh` ผ่าน
- [ ] commit ผ่าน `/commit-fast` แล้ว push branch ที่ทำอยู่ขึ้น `origin`
