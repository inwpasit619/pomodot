// Core holds every rule of Pomodot: the timer, the Cycle count, Skip / Reset /
// New Cycle, Expected finish, banner text, History by day and week, where the
// Floating Window goes, and the data files.
//
// It imports Foundation only. scripts/build-app.sh fails the build if anything
// here imports AppKit, SwiftUI or UserNotifications.
