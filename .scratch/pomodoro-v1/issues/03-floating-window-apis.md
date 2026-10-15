# หน้าต่างลอยบนสุด + menu bar ทำได้ด้วย API อะไร ต้อง macOS ขั้นต่ำเท่าไหร่

Type: research
Label: wayfinder:research
Status: resolved
Map: [Map: Pomodoro ลอยบนจอ](../map.md)
Findings: branch `research/floating-window-apis` → `docs/research/floating-window-apis.md`

## Question

ทางเลือกในการทำหน้าต่างเล็กๆ ที่ **ลอยอยู่บนสุดเสมอ แต่สลับเปิด/ปิดได้ตอนแอพรันอยู่** บน macOS ด้วย Swift มีอะไรบ้าง และแต่ละทางต้องใช้ macOS ขั้นต่ำเวอร์ชันไหน

- SwiftUI ล้วน (เช่น `.windowLevel(.floating)`, `WindowGroup`/`Window`, `.windowStyle(.plain)`, `.windowResizability`) กับ AppKit `NSPanel` / `NSWindow.level` ที่ห่อด้วย SwiftUI
- ให้หน้าต่างไปอยู่ทุก Space ได้ไหม (`collectionBehavior` `.canJoinAllSpaces`) และขึ้นทับแอพที่เปิด fullscreen ได้ไหม (`.fullScreenAuxiliary`)
- ทำหน้าต่างไม่มี title bar ลากย้ายได้ ไม่แย่ง focus จากแอพอื่น (non-activating panel) ได้ไหม
- menu bar: `MenuBarExtra` (SwiftUI, macOS 13+) กับ `NSStatusItem` อันไหนแสดงเวลานับถอยหลังบน menu bar ได้ลื่นกว่า
- ซ่อน Dock icon (`LSUIElement` / activation policy `.accessory`) แล้วมีผลอะไรตามมาบ้าง

สรุปเป็นตาราง: ทางเลือก × macOS ขั้นต่ำ × ข้อดีข้อเสีย พร้อมทางที่แนะนำ

## Answer

(ปิดโดย research subagent รายละเอียดและแหล่งอ้างอิงดูที่ branch `research/floating-window-apis` ไฟล์ `docs/research/floating-window-apis.md` commit defe57f บรรทัดที่ติด [observed] มาจาก probe app ที่รันจริงบนเครื่องนี้)

- **ทางที่แนะนำ:** ใช้ SwiftUI ทำ UI, ใช้ `MenuBarExtra` ทำ menu bar และใช้ **AppKit `NSPanel` ห่อ SwiftUI view** ทำหน้าต่างลอย macOS ขั้นต่ำที่แนะนำคือ **14** เพราะได้ `NSApp.activate()` มาใช้ ส่วน `activate(ignoringOtherApps:)` ถูก deprecate ใน 27.0 (ถ้าใช้ NSPanel อย่างเดียว compile บน 13 ได้)
- **SwiftUI ล้วนไม่พอ:** ต้องใช้ macOS 15 ขึ้นไป สลับ always-on-top ระหว่างรันได้ [observed] แต่ไม่มี API ที่กันไม่ให้หน้าต่างแย่ง focus และพอหน้าต่างอัปเดต SwiftUI จะ reset `collectionBehavior` ทิ้ง ทำให้ขึ้นทับแอพที่เปิด fullscreen ไม่ได้ [observed] ส่วน `UtilityWindow` ซ่อนตัวเวลาแอพไม่ active
- **`NSPanel` ทำได้ครบทั้ง 4 ข้อ:** สลับ always-on-top ระหว่างรันได้ (`level = .floating / .normal` [observed]), อยู่ทุก Space, ขึ้นทับแอพ fullscreen และไม่แย่ง focus สองข้อหลังยืนยันจากเอกสาร Apple อย่างเดียว ยังไม่ได้คลิกทดสอบเอง **ใน spec ต้องมีขั้นตอนทดสอบด้วยมือ**
- **เวลานับถอยหลังบน menu bar:** `MenuBarExtra` กับ `NSStatusItem` อัปเดตสดได้ทั้งคู่ [observed] แนะนำ `MenuBarExtra` ใช้ตัวเลข monospaced
- **ถ้าซ่อน Dock icon** (`LSUIElement` / `.accessory`) จะไม่มีเมนูแอพด้านบนจอ และไม่ขึ้นใน Cmd-Tab ทำให้ปุ่ม Quit กับ Settings ต้องย้ายไปอยู่ในเมนูบน menu bar ปิดหน้าต่างแล้วแอพไม่ออก และเรียกกลับมาได้ด้วย `openWindow` [observed] (ตัดสินใจในตั๋ว "menu bar กับหน้าต่างลอย เกี่ยวกันยังไง")
- **กับดักที่ต้องบอก coding agent:** SwiftUI window แบบ `.plain` ที่ขนาดเปลี่ยนตามข้อความ crash ใน Auto Layout (`NSGenericException`) แก้ได้ด้วยการกำหนด `.frame(width:height:)` ตายตัวที่ root view
- **toolchain บนเครื่องนี้พัง** (ส่งต่อให้ตั๋ว "ติดตั้ง Xcode หรือใช้แค่ Command Line Tools"): `swift build` link ไม่ผ่านแม้แต่ Package.swift ว่างๆ ส่วน `swiftc` ก็พังเพราะ module map ใน `/Library/Developer/CommandLineTools/usr/include/swift/` นิยาม `SwiftBridging` ซ้ำกัน ตอนนี้เลี่ยงไปก่อนด้วย `swiftc -vfsoverlay` ทางแก้ถาวรน่าจะเป็นลบไฟล์ module.modulemap ตัวเก่าปี 2023 หรือติดตั้ง CLT ใหม่ (ยังไม่ได้ทำทั้งสองอย่าง)
