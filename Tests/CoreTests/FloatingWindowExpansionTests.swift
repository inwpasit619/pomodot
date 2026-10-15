import CoreGraphics
import Foundation
import Testing
import Core

/// The usable area from the spec's examples, with the capsule centred at (720, 850).
private let screen = CGRect(x: 0, y: 0, width: 1440, height: 875)
private let topCapsule = CGRect(x: 656, y: 831, width: 128, height: 38)

@Test("Given the pointer rests on the capsule from t = 0, when t = 0.3 comes, then it expands into the card")
func restingThreeTenthsOfASecondExpands() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.pointerEntered(at: second(0))

    // When
    window.check(at: second(0.3), visibleFrame: screen)

    // Then
    #expect(window.isExpanded)
}

@Test("Given the pointer enters the capsule at t = 0 and leaves at t = 0.2, when t = 0.3 comes, then it stays a capsule")
func passingOverQuicklyDoesNotExpand() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.pointerEntered(at: second(0))
    window.pointerExited(at: second(0.2))

    // When
    window.check(at: second(0.3), visibleFrame: screen)

    // Then
    #expect(!window.isExpanded)
}

/// A Floating Window already open into the card, with the pointer on it.
private func expandedWindow() -> FloatingWindowExpansion {
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.pointerEntered(at: second(-1))
    window.check(at: second(-0.7), visibleFrame: screen)
    return window
}

@Test("Given the card is open and the pointer leaves at t = 0, when t = 0.5 comes, then it closes back into the capsule")
func leavingForHalfASecondCollapses() {
    // Given
    var window = expandedWindow()
    window.pointerExited(at: second(0))

    // When
    window.check(at: second(0.5), visibleFrame: screen)

    // Then
    #expect(!window.isExpanded)
}

@Test("Given the card is open, the pointer leaves at t = 0 and comes back at t = 0.4, when t = 0.5 comes, then the card stays open")
func comingBackInTimeKeepsTheCardOpen() {
    // Given
    var window = expandedWindow()
    window.pointerExited(at: second(0))
    window.pointerEntered(at: second(0.4))

    // When
    window.check(at: second(0.5), visibleFrame: screen)

    // Then
    #expect(window.isExpanded)
}

@Test("Given the pointer has just entered the capsule, when it is pressed and released without moving, then it expands straight away")
func clickingTheCapsuleExpandsAtOnce() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.pointerEntered(at: second(0))

    // When
    window.pressed(at: CGPoint(x: 700, y: 850))
    window.released(at: CGPoint(x: 700, y: 850), visibleFrame: screen)

    // Then
    #expect(window.isExpanded)
}

@Test("Given the pointer enters the capsule at t = 0 and presses it at t = 0.1, when it drags 40 pt and releases at t = 1, then the capsule never expands, until the pointer leaves and rests on it again for 0.3 s")
func draggingTheCapsuleDoesNotExpand() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.pointerEntered(at: second(0))
    window.pressed(at: CGPoint(x: 700, y: 850))

    // When
    window.check(at: second(0.5), visibleFrame: screen)
    let expandedWhileDragging = window.isExpanded
    window.released(at: CGPoint(x: 740, y: 850), visibleFrame: screen)
    window.check(at: second(1), visibleFrame: screen)
    let expandedAfterRelease = window.isExpanded
    window.pointerExited(at: second(2))
    window.pointerEntered(at: second(3))
    window.check(at: second(3.3), visibleFrame: screen)

    // Then
    #expect(!expandedWhileDragging)
    #expect(!expandedAfterRelease)
    #expect(window.isExpanded)
}

@Test("Given the card opened downward from (720, 850), when the usable area changes so the capsule is now in the bottom half, then the card keeps growing down until it closes, and grows up the next time it opens")
func cardKeepsItsDirectionUntilItCloses() {
    // Given
    var window = expandedWindow()
    let tallerScreen = CGRect(x: 0, y: 0, width: 1440, height: 2000)

    // When
    window.check(at: second(0), visibleFrame: tallerScreen)
    let frameWhileOpen = window.frame
    window.pointerExited(at: second(1))
    window.check(at: second(1.5), visibleFrame: tallerScreen)
    window.pointerEntered(at: second(2))
    window.check(at: second(2.3), visibleFrame: tallerScreen)

    // Then
    #expect(frameWhileOpen == CGRect(x: 578, y: 669, width: 284, height: 200))
    #expect(window.frame == CGRect(x: 578, y: 831, width: 284, height: 200))
}

@Test("Given the pointer enters the capsule at t = 0, when the app asks when to check next, then it is t = 0.3; after the card opens and the pointer leaves at t = 1, it is t = 1.5; with nothing pending, there is none")
func itSaysWhenToCheckNext() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    let idle = window.nextCheck

    // When
    window.pointerEntered(at: second(0))
    let afterEntering = window.nextCheck
    window.check(at: second(0.3), visibleFrame: screen)
    window.pointerExited(at: second(1))
    let afterLeaving = window.nextCheck

    // Then
    #expect(idle == nil)
    #expect(afterEntering == second(0.3))
    #expect(afterLeaving == second(1.5))
}

@Test("Given the card is open, when the Floating Window is hidden, then it is a capsule again the next time it shows")
func hidingClosesTheCard() {
    // Given
    var window = expandedWindow()

    // When
    window.hide()

    // Then
    #expect(!window.isExpanded)
    #expect(window.nextCheck == nil)
}

@Test("Given the capsule was moved from the top to be centred at (720, 100), when it expands, then the card grows up from its new place")
func theCardOpensFromWhereTheCapsuleIsNow() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.moveCapsule(to: CGRect(x: 656, y: 81, width: 128, height: 38))

    // When
    window.pressed(at: CGPoint(x: 720, y: 100))
    window.released(at: CGPoint(x: 720, y: 100), visibleFrame: screen)

    // Then
    #expect(window.frame == CGRect(x: 578, y: 81, width: 284, height: 200))
}
