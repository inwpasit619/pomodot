import CoreGraphics
import Foundation
import Testing
import Core

/// The usable area from the spec's examples, with the capsule centred at (720, 850).
private let screen = CGRect(x: 0, y: 0, width: 1440, height: 875)
private let topCapsule = CGRect(x: 656, y: 831, width: 128, height: 38)

@Test("Given the pointer rests on the capsule from t = 0, when t = 2 comes, then it is still a capsule: only a click opens the card")
func restingOnTheCapsuleDoesNotExpand() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.pointerEntered()

    // When
    window.check(at: second(2))

    // Then
    #expect(!window.isExpanded)
}

/// A Floating Window already opened into the card by a click, with the pointer on it.
private func expandedWindow() -> FloatingWindowExpansion {
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.pointerEntered()
    window.pressed(at: CGPoint(x: 720, y: 850))
    window.released(at: CGPoint(x: 720, y: 850), visibleFrame: screen)
    return window
}

@Test("Given the card is open and the pointer leaves at t = 0, when t = 0.5 comes, then it closes back into the capsule")
func leavingForHalfASecondCollapses() {
    // Given
    var window = expandedWindow()
    window.pointerExited(at: second(0))

    // When
    window.check(at: second(0.5))

    // Then
    #expect(!window.isExpanded)
}

@Test("Given the card is open, the pointer leaves at t = 0 and comes back at t = 0.4, when t = 0.5 comes, then the card stays open")
func comingBackInTimeKeepsTheCardOpen() {
    // Given
    var window = expandedWindow()
    window.pointerExited(at: second(0))
    window.pointerEntered()

    // When
    window.check(at: second(0.5))

    // Then
    #expect(window.isExpanded)
}

@Test("Given the pointer has just entered the capsule, when it is pressed and released without moving, then it expands straight away")
func clickingTheCapsuleExpandsAtOnce() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.pointerEntered()

    // When
    window.pressed(at: CGPoint(x: 700, y: 850))
    window.released(at: CGPoint(x: 700, y: 850), visibleFrame: screen)

    // Then
    #expect(window.isExpanded)
}

@Test("Given the pointer enters the capsule at t = 0 and presses it at t = 0.1, when it drags 40 pt and releases at t = 1, then the capsule doesn't expand while dragging or after, until it is clicked")
func draggingTheCapsuleDoesNotExpand() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.pointerEntered()
    window.pressed(at: CGPoint(x: 700, y: 850))

    // When
    window.dragged(to: CGPoint(x: 740, y: 850), visibleFrame: screen)
    window.check(at: second(0.5))
    let expandedWhileDragging = window.isExpanded
    window.released(at: CGPoint(x: 740, y: 850), visibleFrame: screen)
    window.check(at: second(1))
    let expandedAfterRelease = window.isExpanded
    window.pressed(at: CGPoint(x: 740, y: 850))
    window.released(at: CGPoint(x: 740, y: 850), visibleFrame: screen)

    // Then
    #expect(!expandedWhileDragging)
    #expect(!expandedAfterRelease)
    #expect(window.isExpanded)
}

@Test("Given the card opened downward from (720, 850), when it is dragged so the capsule sits away from every edge at (720, 350), then the card keeps growing down until it closes, and grows out from its middle when clicked open again")
func cardKeepsItsDirectionUntilItCloses() {
    // Given
    var window = expandedWindow()

    // When
    window.pressed(at: CGPoint(x: 720, y: 800))
    window.dragged(to: CGPoint(x: 720, y: 300), visibleFrame: screen)
    window.released(at: CGPoint(x: 720, y: 300), visibleFrame: screen)
    let frameWhileOpen = window.frame
    window.pointerExited(at: second(1))
    window.check(at: second(1.5))
    window.pointerEntered()
    window.pressed(at: CGPoint(x: 720, y: 350))
    window.released(at: CGPoint(x: 720, y: 350), visibleFrame: screen)

    // Then
    #expect(frameWhileOpen == CGRect(x: 578, y: 169, width: 284, height: 200))
    #expect(window.frame == CGRect(x: 578, y: 250, width: 284, height: 200))
}

@Test("Given the pointer enters the capsule at t = 0, when the app asks when to check next, then there is nothing to check; after a click opens the card and the pointer leaves at t = 1, it is t = 1.5")
func itSaysWhenToCheckNext() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)

    // When
    window.pointerEntered()
    let afterEntering = window.nextCheck
    window.pressed(at: CGPoint(x: 720, y: 850))
    window.released(at: CGPoint(x: 720, y: 850), visibleFrame: screen)
    window.pointerExited(at: second(1))
    let afterLeaving = window.nextCheck

    // Then
    #expect(afterEntering == nil)
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

@Test("Given the capsule was dragged from the top to be centred at (720, 60), near the bottom edge, when it expands, then the card grows up from its new place")
func theCardOpensFromWhereTheCapsuleIsNow() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.pressed(at: CGPoint(x: 720, y: 850))
    window.dragged(to: CGPoint(x: 720, y: 60), visibleFrame: screen)
    window.released(at: CGPoint(x: 720, y: 60), visibleFrame: screen)

    // When
    window.pressed(at: CGPoint(x: 720, y: 60))
    window.released(at: CGPoint(x: 720, y: 60), visibleFrame: screen)

    // Then
    #expect(window.frame == CGRect(x: 578, y: 41, width: 284, height: 200))
}

@Test("Given the capsule is pressed at (700, 850), when it is dragged to (1500, 850) and then to (700, -200), then it stops at the right edge of the usable area, then at the bottom edge")
func draggingPastTheEdgeStopsAtTheUsableArea() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.pressed(at: CGPoint(x: 700, y: 850))

    // When
    window.dragged(to: CGPoint(x: 1500, y: 850), visibleFrame: screen)
    let atRightEdge = window.capsuleFrame
    window.dragged(to: CGPoint(x: 700, y: -200), visibleFrame: screen)
    let atBottomEdge = window.capsuleFrame

    // Then
    #expect(atRightEdge == CGRect(x: 1312, y: 831, width: 128, height: 38))
    #expect(atBottomEdge == CGRect(x: 656, y: 0, width: 128, height: 38))
}

@Test("Given the capsule is pressed at (700, 850), when the pointer wobbles 2 pt and comes up there, then the capsule stays put and the card opens, as for a click")
func wobblingThreePointsOrLessIsAClick() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.pressed(at: CGPoint(x: 700, y: 850))

    // When
    window.dragged(to: CGPoint(x: 702, y: 850), visibleFrame: screen)
    let afterWobble = window.capsuleFrame
    window.released(at: CGPoint(x: 702, y: 850), visibleFrame: screen)

    // Then
    #expect(afterWobble == topCapsule)
    #expect(window.isExpanded)
}

@Test("Given the capsule is pressed at (700, 850), when the pointer moves 5 pt and then back to the start before coming up, then the capsule followed it and it was a drag, so the card doesn't open")
func movingMoreThanThreePointsIsADrag() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.pressed(at: CGPoint(x: 700, y: 850))

    // When
    window.dragged(to: CGPoint(x: 705, y: 850), visibleFrame: screen)
    let afterFivePoints = window.capsuleFrame
    window.dragged(to: CGPoint(x: 700, y: 850), visibleFrame: screen)
    window.released(at: CGPoint(x: 700, y: 850), visibleFrame: screen)

    // Then
    #expect(afterFivePoints == CGRect(x: 661, y: 831, width: 128, height: 38))
    #expect(!window.isExpanded)
}

@Test("Given the card is open below the capsule at (720, 850), when it is pressed at (700, 800) and dragged to (1500, 800), then the card stops with its right edge at x = 1440, keeps growing down, and stays open after release")
func draggingTheCardKeepsTheWholeCardOnScreen() {
    // Given
    var window = expandedWindow()
    window.pressed(at: CGPoint(x: 700, y: 800))

    // When
    window.dragged(to: CGPoint(x: 1500, y: 800), visibleFrame: screen)
    window.released(at: CGPoint(x: 1500, y: 800), visibleFrame: screen)

    // Then
    #expect(window.frame == CGRect(x: 1156, y: 669, width: 284, height: 200))
    #expect(window.capsuleFrame == CGRect(x: 1234, y: 831, width: 128, height: 38))
    #expect(window.isExpanded)
}

@Test("Given the card is being dragged, when the pointer slips off it at t = 0 and the button is still down at t = 1, then the card stays open with no check pending; once the button comes up away from the card, it closes at the next check")
func theCardStaysOpenWhileItIsDragged() {
    // Given
    var window = expandedWindow()
    window.pressed(at: CGPoint(x: 700, y: 800))
    window.dragged(to: CGPoint(x: 1500, y: 800), visibleFrame: screen)

    // When
    window.pointerExited(at: second(0))
    window.check(at: second(1))
    let openWhileDragging = window.isExpanded
    let checkWhileDragging = window.nextCheck
    window.released(at: CGPoint(x: 1500, y: 800), visibleFrame: screen)
    window.check(at: second(2))

    // Then
    #expect(openWhileDragging)
    #expect(checkWhileDragging == nil)
    #expect(!window.isExpanded)
}

@Test("Given the card is open, when Start is pressed at (720, 690) and the pointer drags 100 pt before coming up, then the card doesn't move and nothing is pressed")
func pressingACardButtonNeverDrags() {
    // Given
    var window = expandedWindow()

    // When
    window.pressed(at: CGPoint(x: 720, y: 690), onButton: true)
    let pressed = window.isPressed
    window.dragged(to: CGPoint(x: 820, y: 690), visibleFrame: screen)
    window.released(at: CGPoint(x: 820, y: 690), visibleFrame: screen)

    // Then
    #expect(!pressed)
    #expect(window.frame == CGRect(x: 578, y: 669, width: 284, height: 200))
}
