# Pomodot

A small Pomodoro timer for macOS. It lives in the menu bar, showing the time left next to its icon, and its Floating Window, a little glass capsule, floats above your other apps (Always on Top, which you can switch off) and opens into a card with every control when you click it.

- Focus, Short Break and Long Break lengths, and Pomodoros per Cycle, all adjustable (25 / 5 / 15 / 4 by default)
- A banner and a sound when a Phase runs out, with your choice of system sound
- Breaks and Focus can start by themselves
- When the current Phase and the whole Cycle will finish
- Statistics: today, this week, all time and the last 7 days
- Light, Dark or following your Mac

Requires macOS 14 Sonoma or later. The app is built for both Apple silicon and Intel Macs.

macOS asks you to confirm Pomodot once before it first opens; the steps below take about a minute. Right-click › Open no longer gets past this on recent macOS, so use Open Anyway as below. Homebrew can't install it either.

## Installing Pomodot (about 1 minute, first time only)

1. Download **Pomodot-X.Y.Z.zip** from the [latest release](https://github.com/inwpasit619/pomodot/releases/latest). Safari unzips it for you, and you'll see **Pomodot** in your Downloads folder. (In another browser, double-click the zip.)
2. Drag **Pomodot** into your **Applications** folder. Opening it straight from Downloads can stop it working properly, so always move it first.
3. Open Applications and double-click **Pomodot**. A warning says macOS can't check it. This is expected, because the app isn't sold through Apple. Click **Done** (not "Move to Trash").
4. Within the next hour, open **System Settings** (Apple menu) and click **Privacy & Security** in the sidebar.
5. Scroll down to **Security**. You'll see a note that Pomodot was blocked. Click **Open Anyway**.
6. Type your Mac login password, then click **Open** when the warning appears one last time.
7. Done. From now on, Pomodot opens normally. Look for its icon in the menu bar.

**If that doesn't work** (for example, if it says the app is "damaged"), open the **Terminal** app, paste this line, press Return, and then open Pomodot again:

```
xattr -dr com.apple.quarantine /Applications/Pomodot.app
```

## Updating

Quit Pomodot from its menu, download the new zip, and drag the new **Pomodot** into Applications to replace the old one. Your History and Settings are kept. macOS blocks the new version too (tested on macOS 27), so do steps 3–6 above again for it.

Going back to an older version isn't supported.

## Uninstalling

1. Quit Pomodot and drag it from Applications to the Trash. Deleting the app alone keeps your History.
2. To delete your data too: in Finder choose **Go › Go to Folder…**, enter `~/Library/Application Support/com.teppasit.pomodot`, and delete that folder.
3. Optional: remove Pomodot from **System Settings › Notifications**.

## ภาษาไทย

### ติดตั้ง Pomodot (ครั้งแรกใช้เวลาประมาณ 1 นาที)

1. ดาวน์โหลด **Pomodot-X.Y.Z.zip** จาก[หน้า release ล่าสุด](https://github.com/inwpasit619/pomodot/releases/latest) Safari จะแตกไฟล์ให้เอง แล้วจะเห็น **Pomodot** อยู่ในโฟลเดอร์ Downloads (ถ้าใช้ browser อื่น ให้ดับเบิลคลิกไฟล์ zip)
2. ลาก **Pomodot** ไปใส่ในโฟลเดอร์ **Applications** (ถ้าเปิดจาก Downloads ตรงๆ แอพอาจทำงานไม่ถูกต้อง ให้ย้ายก่อนเสมอ)
3. เปิด Applications แล้วดับเบิลคลิก **Pomodot** จะมีคำเตือนว่า macOS ตรวจสอบแอพนี้ไม่ได้ ไม่ต้องตกใจ เป็นเพราะแอพนี้ไม่ได้ขายผ่าน Apple ให้กด **Done** (อย่ากด "Move to Trash")
4. ภายใน 1 ชั่วโมงหลังจากนั้น เปิด **System Settings** (จากเมนู Apple) แล้วคลิก **Privacy & Security** ที่แถบด้านซ้าย
5. เลื่อนลงไปที่หัวข้อ **Security** จะเห็นข้อความว่า Pomodot ถูกบล็อก ให้กด **Open Anyway**
6. ใส่รหัสผ่านที่ใช้ล็อกอินเครื่อง Mac แล้วกด **Open** ตอนที่คำเตือนขึ้นมาเป็นครั้งสุดท้าย
7. เสร็จแล้ว ต่อจากนี้เปิด Pomodot ได้ตามปกติ ไอคอนจะอยู่บน menu bar ด้านบนของจอ

**ถ้ายังเปิดไม่ได้** (เช่น ขึ้นว่าแอพ "damaged") ให้เปิดแอพ **Terminal** วางคำสั่งข้างล่างนี้ กด Return แล้วลองเปิด Pomodot อีกครั้ง:

```
xattr -dr com.apple.quarantine /Applications/Pomodot.app
```

### อัปเดต

Quit Pomodot จากเมนูของมัน ดาวน์โหลด zip ตัวใหม่ แล้วลาก **Pomodot** ตัวใหม่ไปทับตัวเดิมใน Applications History กับ Settings ยังอยู่ครบ macOS จะบล็อกเวอร์ชันใหม่อีกครั้ง (ทดสอบแล้วบน macOS 27) ให้ทำข้อ 3–6 ข้างบนซ้ำอีกรอบ

ไม่รองรับการย้อนกลับไปใช้เวอร์ชันเก่า

### ถอนการติดตั้ง

1. Quit Pomodot แล้วลากออกจาก Applications ลงถังขยะ (ลบแอพอย่างเดียว History ยังอยู่)
2. ถ้าอยากลบข้อมูลด้วย: ใน Finder เลือก **Go › Go to Folder…** พิมพ์ `~/Library/Application Support/com.teppasit.pomodot` แล้วลบโฟลเดอร์นั้น
3. ไม่บังคับ: ลบรายการ Pomodot ใน **System Settings › Notifications**

## Advanced: building from source

You need macOS with Apple's Command Line Tools (`xcode-select --install`); Xcode itself isn't needed. Then, from this folder:

```
scripts/build-app.sh
```

It builds a universal app (Apple silicon and Intel), checks that the timer's rules don't depend on any UI framework, signs the app ad hoc (no Apple Developer account), verifies the signature and leaves it at `dist/Pomodot.app`. `swift test` runs the tests.
