# เลข version และขั้นตอนออก GitHub Release

Type: grilling
Label: wayfinder:grilling
Status: resolved
Assignee: teppasit
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

## Answer

(ปิดเมื่อ 2026-10-15 คุยกับผู้ใช้ agent เป็นคนเสนอ ผู้ใช้อนุมัติหรือเลือกเองทุกข้อ)

**1. Repo = `https://github.com/inwpasit619/pomodot`**
- ผู้ใช้เลือกเอง repo **เป็น public และยังว่างอยู่** (ตรวจแล้ว 2026-10-15) ต้องเป็น public ไม่งั้นเพื่อนจะดาวน์โหลด `.zip` ไม่ได้ถ้าไม่ล็อกอิน
- **push `.scratch/` (map + ตั๋ว) และ `CLAUDE.md` ขึ้นไปด้วย** ไม่ซ่อน
- **ต้องล็อกอินก่อน push ครั้งแรก:** ตอนนี้ `gh` ล็อกอินเป็น `teppasit-lovecode` ซึ่งมีสิทธิ์แค่ READ ใน repo นี้ ส่วน token ของ `inwpasit619` หมดอายุแล้ว ก่อน push ครั้งแรก agent ต้อง**หยุด**แล้วให้ผู้ใช้รัน `! gh auth login` (เลือกบัญชี `inwpasit619`) แล้วตรวจว่า `gh repo view inwpasit619/pomodot --json viewerPermission` ได้ `ADMIN` หรือ `WRITE` ห้ามหาทางอ้อมเอง
- remote ชื่อ `origin`

**2. build บนเครื่อง dev ไม่ใช้ GitHub Actions**
- release ใช้ script ที่ build, ประกอบ `.app` และ sign ตัวเดียวกับเงื่อนไข "เสร็จ" ข้อ 5 (ตั๋ว "spec จะสั่ง agent ให้จัดโครงสร้างโค้ดและทดสอบยังไง") แล้วต่อด้วยขั้นตอน zip + อัปโหลด ทำทั้งหมดใน script เดียว เช่น `scripts/release.sh`
- เหตุผล: toolchain บนเครื่องนี้ทดสอบแล้ว (Swift 6.4 / SDK 27 build universal + ad-hoc sign ผ่าน) ถ้าเป็น CI ผู้ใช้ต้องอ่าน log ของ YAML เอง ข้อเสียที่ยอมรับ: ออก release ได้จากเครื่องนี้เครื่องเดียว

**3. เลข version**
- ใช้รูปแบบ `MAJOR.MINOR.PATCH` แก้บั๊ก = PATCH, เพิ่มฟีเจอร์ = MINOR, เปลี่ยนใหญ่ = MAJOR
- **เวอร์ชันแรกที่แจกเพื่อนคือ `0.9.0`** ออกตอนจบ milestone 5 ถ้าเพื่อนเจอบั๊กก็ออก `0.9.1`, `0.9.2`… ผู้ใช้พอใจเมื่อไหร่ค่อยออก `1.0.0`
- **เก็บเลขไว้ที่เดียวคือไฟล์ `VERSION`** ที่ root ของ repo (มีบรรทัดเดียว เช่น `0.9.0`) script ใส่ค่านี้ลง `Info.plist` เอง ห้ามแก้เลขเองใน `Info.plist`
  - `CFBundleShortVersionString` = ค่าใน `VERSION`
  - `CFBundleVersion` = เลขจำนวนเต็มที่เพิ่มขึ้นทุก build ให้ใช้ `git rev-list --count HEAD` (เพิ่มขึ้นเอง ไม่ต้องจำ และเครื่องอื่นได้เลขเดียวกัน)
- tag ชื่อ `v<version>` (เช่น `v0.9.0`) ไฟล์ชื่อ `Pomodot-<version>.zip`
- **ใครเป็นคนเพิ่มเลข:** ผู้ใช้บอก agent ว่า "ออก release" agent เสนอเลขถัดไปตามกติกาข้างบนพร้อมเหตุผล ผู้ใช้อนุมัติแล้วค่อยเริ่ม

**4. Gitflow (ไม่ต้องมี Pull Request)**

| branch | ใช้ทำอะไร |
|---|---|
| `main` | มีแค่โค้ดที่ออก release แล้ว merge เข้า `main` ทุกครั้งต้องมี tag `vX.Y.Z` (ตอนนี้มีแต่เอกสารวางแผน) |
| `develop` | รวมงานที่ผ่านแล้ว แยกออกจาก `main` ตอนเริ่ม milestone 1 |
| `feature/m1-floating-window`, `feature/m2-timer`, `feature/m3-notifications`, `feature/m4-statistics`, `feature/m5-settings-release` | milestone ละ 1 branch แยกจาก `develop` ผู้ใช้บอก "ผ่าน" แล้วค่อย merge กลับเข้า `develop` |
| `release/X.Y.Z` | แยกจาก `develop` ใช้แก้ `VERSION`, ร่าง release notes และตรวจรอบสุดท้าย จากนั้น merge เข้า `main` + tag แล้ว merge กลับเข้า `develop` |
| `hotfix/X.Y.Z` | แก้บั๊กของเวอร์ชันที่ออกไปแล้ว แยกจาก `main` merge เข้าทั้ง `main` (+ tag) และ `develop` |

- agent merge ในเครื่องเองด้วย `git merge --no-ff` **ไม่เปิด Pull Request** การที่ผู้ใช้บอก "ผ่าน" ในแต่ละ milestone ถือเป็นการรีวิว
- ใช้คำสั่ง git ธรรมดา **ไม่ติดตั้งเครื่องมือ `git-flow`**
- commit ใช้ `/commit-fast` ตาม `CLAUDE.md`
- **push ตั้งแต่ milestone 1** (`main`, `develop` และ feature branch ที่ทำอยู่) เพื่อให้มี backup ส่วนหน้า Releases จะยังว่างจนกว่าจะออก `0.9.0`
- branch `research/*` และ `prototype/*` ที่ใช้ตอนวางแผน **ห้าม push** ให้อยู่ในเครื่องอย่างเดียว

**5. ขั้นตอนของ script ออก release** (ข้อไหนไม่ผ่านให้หยุดทันที ห้ามอัปโหลด)
1. อยู่บน `main` ที่ merge `release/X.Y.Z` หรือ `hotfix/X.Y.Z` เข้ามาแล้ว ไม่มีงานค้างที่ยังไม่ commit และยังไม่มี tag `vX.Y.Z` ทั้งในเครื่องและบน GitHub
2. ผ่านเงื่อนไข "เสร็จ" ทั้ง 7 ข้อของ milestone (test, build universal, ไม่มี warning ใหม่, Core ไม่ import UI, script sign + verify ผ่าน ฯลฯ)
3. ตรวจว่า executable มีทั้ง `arm64` และ `x86_64` (`lipo -archs`)
4. `codesign --verify --strict --deep` บน `Pomodot.app` ต้องผ่าน
5. zip ด้วย `ditto -c -k --keepParent Pomodot.app Pomodot-X.Y.Z.zip` จากนั้น**แตกไฟล์ zip ลงโฟลเดอร์ชั่วคราวด้วย `ditto -x -k` แล้วรัน `codesign --verify --strict --deep` ซ้ำ** ถ้าลายเซ็นเสีย เพื่อนจะเจอข้อความ "damaged" ที่ไม่มีปุ่ม Open Anyway
6. **ห้ามใช้ `spctl --assess` เป็นตัวตัดสิน** แอพที่ไม่ได้ notarize ตรวจด้วย `spctl` ยังไงก็ไม่ผ่าน
7. agent โชว์ release notes ที่ร่างไว้ให้ผู้ใช้ดู → ผู้ใช้อนุมัติ → สร้าง tag `vX.Y.Z`, push `main` + tag + `develop` → `gh release create vX.Y.Z Pomodot-X.Y.Z.zip --title "Pomodot X.Y.Z" --notes-file …` (**ไม่ใส่ `--prerelease`** ลิงก์ `releases/latest` จะได้ชี้ไปที่เวอร์ชันล่าสุดเสมอ) → ดาวน์โหลดไฟล์จาก release กลับมาด้วย `gh release download` แล้วเทียบ `shasum -a 256` ต้องตรงกับไฟล์ในเครื่อง

**6. Release notes ภาษาอังกฤษอย่างเดียว**
- agent ร่างจาก commit ตั้งแต่ tag ก่อนหน้า เขียนเป็นภาษาคน ไม่ใช่ชื่อ commit มี 3 ส่วน: **What's new / Fixed**, **Install or update** (สั้นๆ แล้วลิงก์ไป README), **Your data is kept** (เอาไปทับแอพเดิมได้ History กับ Settings ยังอยู่)
- **ผู้ใช้ต้องอนุมัติก่อนเผยแพร่ทุกครั้ง** เพราะ repo เป็น public

**7. README**
- เขียนภาษาอังกฤษเป็นหลัก + มีหัวข้อ**ภาษาไทย**ของขั้นตอน ติดตั้ง / อัปเดต / ถอนการติดตั้ง (ใช้ร่างจาก research ในตั๋ว "เพื่อนเปิดแอพที่ไม่ได้ notarize จาก GitHub ได้ยังไง")
- ลิงก์ดาวน์โหลดชี้ไปที่ `https://github.com/inwpasit619/pomodot/releases/latest`
- ต้องมี: ขั้นตอน Open Anyway, ติดตั้งด้วยการลากไป Applications (เลี่ยง App Translocation), ทางสำรอง `xattr -dr com.apple.quarantine`, อัปเดตด้วยการเอาไปทับ (ข้อมูลยังอยู่), ถอนการติดตั้งผ่าน Finder (ตั๋ว "เก็บข้อมูลของแอพไว้ที่ไหน รูปแบบอะไร"), ไม่รองรับ downgrade, หมายเหตุ "advanced" สำหรับคนที่อยาก build จาก source เอง

**8. อัปเดต: ไม่มี auto-update มีแค่เมนู**
- เพิ่ม 2 รายการในเมนู dropdown (ตั๋ว "menu bar กับหน้าต่างลอย เกี่ยวกันยังไง") ไว้ในกลุ่มสุดท้ายก่อน Quit:
  ```
  About Pomodot
  Check for Updates…
  ──────────────
  Quit Pomodot
  ```
  - `About Pomodot` = หน้าต่าง About มาตรฐานของ macOS โชว์ไอคอน ชื่อ และเลข version (`0.9.0 (build N)`)
  - `Check for Updates…` = เปิด `https://github.com/inwpasit619/pomodot/releases` ใน browser แอพ**ไม่ต่อเน็ตเอง**
- ไม่มีเงื่อนไขใหม่ใน Core ไม่ต้องเพิ่ม test (URL เก็บเป็นค่าคงที่ใน App)

**9. Open Anyway ตอนอัปเดต: ทดสอบบนเครื่อง dev ใน milestone 5**
- agent ทำ build ทดสอบ 2 ตัวที่ `CFBundleVersion` ต่างกัน ใส่ quarantine ให้เหมือนไฟล์ที่ดาวน์โหลดผ่าน browser (`xattr -w com.apple.quarantine "0081;$(printf %x $(date +%s));Safari;" <zip>` ก่อนแตกไฟล์ด้วย Finder) ผู้ใช้ติดตั้งตัวแรก → กด Open Anyway → เอาตัวที่สองไปทับ → ดูว่า macOS บล็อกอีกไหม
- เขียน README และ release notes ตามผลที่ได้จริง แล้วบันทึกผลไว้ในรายงานของ milestone 5
- ใส่เป็นข้อในหมวด "ติดตั้งบนเครื่องเพื่อน" ของ `docs/manual-test.md` แบบ Given/When/Then

**10. Checklist ทดสอบด้วยมือ (milestone 5)** เพิ่มจากที่มีอยู่แล้ว
- เมนู › About Pomodot → เห็นไอคอน ชื่อ และ `0.9.0`
- เมนู › Check for Updates… → browser เปิดหน้า Releases ของ `inwpasit619/pomodot`
- อัปเดตทับ (ข้อ 9) → History กับ Settings ยังอยู่ และรู้ว่าต้องกด Open Anyway ซ้ำไหม
- เครื่องเพื่อน: ดาวน์โหลด `Pomodot-0.9.0.zip` จาก `releases/latest` → ลากไป Applications → Open Anyway เห็นชื่อ `Pomodot` → ใช้งานได้

**ตัดออกนอก scope:** อัปเดตตัวเองแบบ Sparkle, แอพเช็กเวอร์ชันใหม่เองแล้วเตือน (ถ้าอยากได้ค่อยทำใน v1.x), GitHub Actions
