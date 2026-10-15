# ติดตั้ง Xcode หรือใช้แค่ Command Line Tools

Type: grilling
Label: wayfinder:grilling
Status: open
Map: [Map: Pomodoro ลอยบนจอ](../map.md)
Blocked by: 01

## Question

จากผลตั๋ว "ใช้แค่ Command Line Tools สร้าง .app ที่ใช้งานได้จริงไหม" จะติดตั้ง Xcode (ฟรี, ประมาณ 10GB+) หรือ build ด้วย SwiftPM + Command Line Tools อย่างเดียว ทางไหนทำให้ agent build, run และแพ็กแอพได้ครบโดยที่ผู้ใช้ไม่ต้องเปิด Xcode เอง (agent แนะนำ ผู้ใช้อนุมัติ)

ข้อมูลเพิ่มจาก research: ทาง CLT-only ใช้ได้ครบสำหรับ v1 แต่ **Command Line Tools บนเครื่องนี้พังอยู่** สิ่งที่ต้องตัดสินจริงๆ คือจะซ่อมด้วยการติดตั้ง CLT ใหม่ (`sudo rm -rf /Library/Developer/CommandLineTools` + `xcode-select --install`) หรือติดตั้ง Xcode ทั้งตัว แล้ว spec จะยึด toolchain ไหน
