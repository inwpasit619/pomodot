# Pomodot

A small Pomodoro timer for macOS. Its Floating Window, a little glass capsule, floats above your other apps (Always on Top, which you can switch off) and opens into a card with every control when you click it. Pomodot also shows the time left next to its icon in the menu bar, and has an icon in the Dock, which you can switch off. You can do everything from the capsule without touching the menu bar.

- Focus, Short Break and Long Break lengths, and Pomodoros per Cycle, all adjustable (25 / 5 / 15 / 4 by default)
- A banner and a sound when a Phase runs out, with your choice of system sound
- Breaks and Focus can start by themselves
- When the current Phase and the whole Cycle will finish
- Statistics: today, this week, all time and the last 7 days
- Light, Dark or following your Mac
- Opens by itself when you log in, if you like

Requires macOS 14 Sonoma or later. The app is built for both Apple silicon and Intel Macs.

macOS asks you to confirm Pomodot once before it first opens; the steps below take about a minute. Right-click › Open no longer gets past this on recent macOS, so use Open Anyway as below. Homebrew can't install it either.

## Installing Pomodot (about 1 minute, first time only)

1. Download **Pomodot-X.Y.Z.zip** from the [latest release](https://github.com/inwpasit619/pomodot/releases/latest). Safari unzips it for you, and you'll see **Pomodot** in your Downloads folder. (In another browser, double-click the zip.)
2. Drag **Pomodot** into your **Applications** folder. Opening it straight from Downloads can stop it working properly, so always move it first.
3. Open Applications and double-click **Pomodot**. A warning says macOS can't check it. This is expected, because the app isn't sold through Apple. Click **Done** (not "Move to Trash").
4. Within the next hour, open **System Settings** (Apple menu) and click **Privacy & Security** in the sidebar.
5. Scroll down to **Security**. You'll see a note that Pomodot was blocked. Click **Open Anyway**.
6. Type your Mac login password, then click **Open** when the warning appears one last time.
7. Done. From now on, Pomodot opens normally. Look for the capsule near the top of your screen, and Pomodot's icon in the Dock and in the menu bar.

**If that doesn't work** (for example, if it says the app is "damaged"), open the **Terminal** app, paste this line, press Return, and then open Pomodot again:

```
xattr -dr com.apple.quarantine /Applications/Pomodot.app
```

## Using Pomodot

- **The card:** click the capsule to open it into the card, with Start / Pause, Reset and Skip. Move the pointer away and it closes again. Drag the capsule anywhere. Drag the open card near an edge or corner of the screen and it closes into that edge or corner.
- **Everything else:** click the **…** button at the top right of the card, or right-click (or Control-click) the capsule or the card. That menu has **New Cycle…**, **Hide Floating Window**, **Always on Top**, **Statistics…**, **Settings…**, **About Pomodot**, **Check for Updates…** and **Quit Pomodot**.
- **Other ways in:** the menu bar icon's menu also has all of these. Right-clicking Pomodot's Dock icon shows them too, with macOS's own Quit in place of Quit Pomodot.
- **Hiding the capsule:** choose **Hide Floating Window**. Pomodot keeps running. To bring the capsule back, click Pomodot in the Dock (while Show in Dock is on), or open Pomodot again from Spotlight or Launchpad. It also shows again whenever Pomodot opens.
- **Settings › General:**
  - **Open at login** (off at first): Pomodot opens by itself when you log in. If macOS wants your approval first, an orange line appears under the switch; click **Open Login Items…** and allow Pomodot there.
  - **Show in Dock** (on at first): Pomodot's icon in the Dock and in Command-Tab. Switch it off if you'd rather keep it to the capsule and the menu bar.

## Updating

Quit Pomodot (choose **Quit Pomodot** from the card's **…** menu or the menu bar icon), download the new zip, and drag the new **Pomodot** into Applications to replace the old one. Your History and Settings are kept. macOS blocks the new version too (tested on macOS 27), so do steps 3–6 above again for it.

If **Open at login** is on, open the new Pomodot yourself once, and do **Open Anyway**, before you restart or log out. Otherwise macOS may block it when you log in.

Coming from 0.9.0, Pomodot's icon now shows in the Dock. If you don't want it, switch off **Settings › General › Show in Dock**.

Going back to an older version isn't supported.

## Uninstalling

1. If you turned on **Open at login**, switch it off first in **Settings › General**.
2. Quit Pomodot and drag it from Applications to the Trash. Deleting the app alone keeps your History.
3. To delete your data too: in Finder choose **Go › Go to Folder…**, enter `~/Library/Application Support/com.teppasit.pomodot`, and delete that folder.
4. Optional: remove Pomodot from **System Settings › Notifications**.

If you deleted the app with **Open at login** still on, Pomodot stays in **System Settings › General › Login Items & Extensions** (on macOS 14: **Login Items**) with a yellow warning triangle. Select it there and click the **−** button.

## ภาษาไทย

### ติดตั้ง Pomodot (ครั้งแรกใช้เวลาประมาณ 1 นาที)

1. ดาวน์โหลด **Pomodot-X.Y.Z.zip** จาก[หน้า release ล่าสุด](https://github.com/inwpasit619/pomodot/releases/latest) Safari จะแตกไฟล์ให้เอง แล้วจะเห็น **Pomodot** อยู่ในโฟลเดอร์ Downloads (ถ้าใช้ browser อื่น ให้ดับเบิลคลิกไฟล์ zip)
2. ลาก **Pomodot** ไปใส่ในโฟลเดอร์ **Applications** (ถ้าเปิดจาก Downloads ตรงๆ แอพอาจทำงานไม่ถูกต้อง ให้ย้ายก่อนเสมอ)
3. เปิด Applications แล้วดับเบิลคลิก **Pomodot** จะมีคำเตือนว่า macOS ตรวจสอบแอพนี้ไม่ได้ ไม่ต้องตกใจ เป็นเพราะแอพนี้ไม่ได้ขายผ่าน Apple ให้กด **Done** (อย่ากด "Move to Trash")
4. ภายใน 1 ชั่วโมงหลังจากนั้น เปิด **System Settings** (จากเมนู Apple) แล้วคลิก **Privacy & Security** ที่แถบด้านซ้าย
5. เลื่อนลงไปที่หัวข้อ **Security** จะเห็นข้อความว่า Pomodot ถูกบล็อก ให้กด **Open Anyway**
6. ใส่รหัสผ่านที่ใช้ล็อกอินเครื่อง Mac แล้วกด **Open** ตอนที่คำเตือนขึ้นมาเป็นครั้งสุดท้าย
7. เสร็จแล้ว ต่อจากนี้เปิด Pomodot ได้ตามปกติ จะเห็นแคปซูลอยู่ด้านบนของจอ และไอคอนของ Pomodot บน Dock กับบน menu bar

**ถ้ายังเปิดไม่ได้** (เช่น ขึ้นว่าแอพ "damaged") ให้เปิดแอพ **Terminal** วางคำสั่งข้างล่างนี้ กด Return แล้วลองเปิด Pomodot อีกครั้ง:

```
xattr -dr com.apple.quarantine /Applications/Pomodot.app
```

### ใช้งาน

- **การ์ด:** คลิกแคปซูลแล้วจะขยายเป็นการ์ดที่มีปุ่ม Start / Pause, Reset และ Skip เอาเมาส์ออกแล้วการ์ดจะหุบเอง ลากแคปซูลไปไว้ตรงไหนก็ได้ ถ้าลากการ์ดที่ขยายอยู่ไปใกล้ขอบหรือมุมจอ การ์ดจะหุบเข้าขอบหรือมุมนั้น
- **คำสั่งอื่นๆ:** กดปุ่ม **…** มุมขวาบนของการ์ด หรือคลิกขวา (หรือกด Control ค้างแล้วคลิก) ที่แคปซูลหรือการ์ด จะมีเมนู **New Cycle…**, **Hide Floating Window**, **Always on Top**, **Statistics…**, **Settings…**, **About Pomodot**, **Check for Updates…** และ **Quit Pomodot**
- **ทางอื่น:** เมนูของไอคอนบน menu bar ก็มีคำสั่งเหล่านี้ครบ และคลิกขวาที่ไอคอน Pomodot บน Dock ก็เห็นคำสั่งเหล่านี้ (ตรง Quit Pomodot จะเป็นปุ่ม Quit ของ macOS แทน)
- **ซ่อนแคปซูล:** เลือก **Hide Floating Window** แล้ว Pomodot ยังทำงานอยู่ อยากให้แคปซูลกลับมา ให้คลิก Pomodot บน Dock (ตอนเปิด Show in Dock อยู่) หรือเปิด Pomodot อีกครั้งจาก Spotlight หรือ Launchpad และทุกครั้งที่เปิด Pomodot แคปซูลจะโผล่เสมอ
- **Settings › General:**
  - **Open at login** (เริ่มต้นปิด): Pomodot เปิดเองตอน login ถ้า macOS ต้องให้อนุมัติก่อน จะมีบรรทัดสีส้มใต้สวิตช์ ให้กด **Open Login Items…** แล้วอนุญาต Pomodot ในหน้านั้น
  - **Show in Dock** (เริ่มต้นเปิด): ไอคอน Pomodot บน Dock และใน Command-Tab ปิดได้ถ้าอยากใช้แค่แคปซูลกับ menu bar

### อัปเดต

Quit Pomodot (เลือก **Quit Pomodot** จากเมนู **…** ของการ์ด หรือจากไอคอนบน menu bar) ดาวน์โหลด zip ตัวใหม่ แล้วลาก **Pomodot** ตัวใหม่ไปทับตัวเดิมใน Applications History กับ Settings ยังอยู่ครบ macOS จะบล็อกเวอร์ชันใหม่อีกครั้ง (ทดสอบแล้วบน macOS 27) ให้ทำข้อ 3–6 ข้างบนซ้ำอีกรอบ

ถ้าเปิด **Open at login** ไว้ ให้เปิด Pomodot ตัวใหม่เองหนึ่งครั้งและทำ **Open Anyway** ให้เสร็จ ก่อนรีสตาร์ทหรือ log out ไม่งั้นตอน login macOS อาจบล็อกไว้

ถ้าอัปเดตจาก 0.9.0 จะเห็นไอคอน Pomodot โผล่บน Dock ถ้าไม่อยากได้ ปิดได้ที่ **Settings › General › Show in Dock**

ไม่รองรับการย้อนกลับไปใช้เวอร์ชันเก่า

### ถอนการติดตั้ง

1. ถ้าเปิด **Open at login** ไว้ ให้ปิดใน **Settings › General** ก่อน
2. Quit Pomodot แล้วลากออกจาก Applications ลงถังขยะ (ลบแอพอย่างเดียว History ยังอยู่)
3. ถ้าอยากลบข้อมูลด้วย: ใน Finder เลือก **Go › Go to Folder…** พิมพ์ `~/Library/Application Support/com.teppasit.pomodot` แล้วลบโฟลเดอร์นั้น
4. ไม่บังคับ: ลบรายการ Pomodot ใน **System Settings › Notifications**

ถ้าลบแอพไปแล้วโดยที่ยังเปิด **Open at login** ไว้ Pomodot จะค้างอยู่ใน **System Settings › General › Login Items & Extensions** (macOS 14 ชื่อว่า **Login Items**) พร้อมสามเหลี่ยมสีเหลือง ให้เลือก Pomodot ในหน้านั้นแล้วกดปุ่ม **−**

## Advanced: building from source

You need macOS with Apple's Command Line Tools (`xcode-select --install`); Xcode itself isn't needed. Then, from this folder:

```
scripts/build-app.sh
```

It builds a universal app (Apple silicon and Intel), checks that the timer's rules don't depend on any UI framework, signs the app ad hoc (no Apple Developer account), verifies the signature and leaves it at `dist/Pomodot.app`. `swift test` runs the tests.
