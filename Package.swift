// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Pomodot",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "Pomodot", targets: ["Pomodot"]),
    ],
    targets: [
        // Rules only. Must not import AppKit, SwiftUI or UserNotifications;
        // never reads the clock itself and never owns a timer.
        .target(name: "Core"),
        // The app: menu bar, Floating Window, windows, sound, notifications, disk.
        .executableTarget(name: "Pomodot", dependencies: ["Core"]),
        .testTarget(name: "CoreTests", dependencies: ["Core"]),
    ]
)
