# หน้าต่างลอยบนสุด + menu bar ทำได้ด้วย API อะไร ต้อง macOS ขั้นต่ำเท่าไหร่

Type: research
Label: wayfinder:research
Status: open
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
