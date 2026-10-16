# 01 — M1 · โครงแอพที่ build และเปิดได้จริง

**Milestone:** M1 · branch `feature/m1-floating-window` (ใบนี้สร้าง `develop` จาก `main` ก่อน แล้วแยก feature branch ออกจาก `develop`)
**อ้างอิง spec:** [spec](../../pomodoro-v1/spec.md) หัวข้อ A4, A5, A7, M1 › ขอบเขต

**What to build:** รันคำสั่งเดียวแล้วได้ `Pomodot.app` ที่ sign ทั้ง bundle และ verify ผ่าน เปิดด้วย `open` แล้วไม่มีไอคอนใน Dock ไม่อยู่ใน Cmd-Tab และไม่มีเมนูแอพด้านบนจอ บน menu bar มีไอคอน `timer` (ยังไม่มีเวลา) คลิกแล้วได้เมนูที่มี `Quit Pomodot` ซึ่งใช้ออกจากแอพได้ ใน Finder แอพแสดงไอคอนแบบ A (แคปซูลขาวบนพื้นแดง) และชื่อ `Pomodot` ตั้งแต่ใบนี้ เบื้องหลังมี Core / Pomodot / CoreTests ครบ และมี model `@Observable` ระดับแอพตัวเดียวไว้ให้ menu bar กับ Floating Window ใช้ร่วมกันในใบถัดไป

**Blocked by:** None — can start immediately

**Status:** ready-for-agent

- [ ] มี branch `develop` ที่แยกจาก `main` และงานอยู่บน `feature/m1-floating-window`
- [ ] package มี 3 target ตาม A5 (Core เป็น library, `Pomodot` เป็น executable, CoreTests ใช้ Swift Testing) ขั้นต่ำ macOS 14 ไม่มี dependency ภายนอก
- [ ] `VERSION` = `0.9.0` และ template ของ `Info.plist` มี key ครบตามตาราง A4 ข้อ 5 โดยให้ script ใส่ version และ build number เอง
- [ ] `.gitignore` มี `.build/` และโฟลเดอร์ผลลัพธ์ของ script
- [ ] ไอคอนต้นฉบับ copy จาก `.scratch/pomodoro-v1/assets/app-icon.svg` ไปไว้ที่ `Packaging/AppIcon.svg` และ `scripts/make-icon.sh` สร้าง `Pomodot.icns` ครบทุกขนาด (16–512 ทั้ง @1x และ @2x) ตาม A4 › ไอคอนแอพ
- [ ] `scripts/build-app.sh` ทำครบในคำสั่งเดียว: build universal → หา path ด้วย `--show-bin-path` (ห้ามเขียน path ตายตัว) → ประกอบ `.app` → `codesign --force --sign -` ที่ตัว `.app` → `codesign --verify --strict --deep` ผ่าน → ใช้ grep ตรวจว่า Core ไม่ import AppKit / SwiftUI / UserNotifications (เจอเมื่อไหร่ script ล้มเหลว)
- [ ] ตอนเปิดแอพ เช็กว่า SF Symbols `timer`, `cup.and.saucer.fill`, `pause.circle` โหลดได้จริง ถ้าตัวไหนได้ `nil` ให้หยุดแล้วรายงานผู้ใช้ **ห้ามเปลี่ยนไปใช้ตัวอื่นเอง**
- [ ] `swift test` รันได้ (target CoreTests มีอยู่จริง ส่วน test จริงตัวแรกจะมาในใบ 02)
- [ ] `swift build -c release --arch arm64 --arch x86_64` ผ่าน โดยมี warning แค่ 2 ตัวที่ A4 บอกว่าไม่ต้องสนใจ
- [ ] agent เปิดแอพด้วย `open` แล้วถ่าย screenshot ของ menu bar กับเมนู dropdown
- [ ] สร้าง `docs/manual-test.md` แบ่งหมวดตาม A7 แล้วเพิ่มข้อ M1: ไอคอนใน Finder (ผู้ใช้ต้องบอกผ่านเรื่องหน้าตาของไอคอน), ไม่มีใน Dock และ Cmd-Tab, มีไอคอน `timer` บน menu bar ที่คลิกแล้วได้เมนู
- [ ] commit ผ่าน `/commit-fast` (ห้ามรัน `git commit` เอง) ยังไม่ต้อง push เพราะ push ครั้งแรกอยู่ในใบ 03
