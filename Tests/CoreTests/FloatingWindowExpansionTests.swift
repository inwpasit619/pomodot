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

@Test("Given the card opened downward from (720, 850), when it is dragged to x 578–862, y 169–369, away from every edge, and let go, then the card stays put with the capsule in its middle, and opens there again once closed")
func cardDraggedAwayFromTheEdgesTucksIntoItsMiddle() {
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
    #expect(window.capsuleFrame == CGRect(x: 656, y: 250, width: 128, height: 38))
    #expect(window.frame == CGRect(x: 578, y: 169, width: 284, height: 200))
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

@Test("Given the card is open below the capsule at (720, 850), when it is pressed at (700, 800) and dragged to (1500, 800), then the card stops with its right edge at x = 1440, keeps growing down, and stays open after release with the capsule tucked into its top-right corner")
func draggingTheCardKeepsTheWholeCardOnScreen() {
    // Given
    var window = expandedWindow()
    window.pressed(at: CGPoint(x: 700, y: 800))

    // When
    window.dragged(to: CGPoint(x: 1500, y: 800), visibleFrame: screen)
    window.released(at: CGPoint(x: 1500, y: 800), visibleFrame: screen)

    // Then
    #expect(window.frame == CGRect(x: 1156, y: 669, width: 284, height: 200))
    #expect(window.capsuleFrame == CGRect(x: 1312, y: 831, width: 128, height: 38))
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

// MARK: The card's menu

@Test("Given the card is open, when its menu opens and the pointer leaves the card for 2 seconds, then the card stays open")
func cardStaysOpenWhileItsMenuIsOpen() {
    // Given
    var window = expandedWindow()

    // When
    window.menuOpened()
    window.pointerExited(at: second(0))
    window.check(at: second(2))

    // Then
    #expect(window.isExpanded)
    #expect(window.nextCheck == nil)
}

@Test("Given the menu is open and the pointer has left the card, when the menu closes at t = 10, then the card is still open at t = 10.4 and closes at t = 10.5")
func awayCountStartsWhenTheMenuCloses() {
    // Given
    var window = expandedWindow()
    window.menuOpened()
    window.pointerExited(at: second(0))

    // When
    window.menuClosed(at: second(10))
    let nextCheck = window.nextCheck
    window.check(at: second(10.4))
    let openAt10_4 = window.isExpanded
    window.check(at: second(10.5))

    // Then
    #expect(nextCheck == second(10.5))
    #expect(openAt10_4)
    #expect(!window.isExpanded)
}

@Test("Given the menu is open, when it closes with the pointer on the card, then the card stays open")
func menuClosingOnTheCardKeepsItOpen() {
    // Given
    var window = expandedWindow()
    window.menuOpened()
    window.pointerExited(at: second(0))
    window.pointerEntered()

    // When
    window.menuClosed(at: second(3))
    window.check(at: second(10))

    // Then
    #expect(window.isExpanded)
    #expect(window.nextCheck == nil)
}

@Test("Given the capsule is closed, when it is right-clicked (its menu opens, then closes), then it stays a capsule")
func rightClickingTheCapsuleKeepsItClosed() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: topCapsule)
    window.pointerEntered()

    // When
    window.menuOpened()
    window.menuClosed(at: second(1))
    window.check(at: second(2))

    // Then
    #expect(!window.isExpanded)
    #expect(window.capsuleFrame == topCapsule)
}

@Test("Given the card's menu is open, when the Floating Window is hidden and its close never arrives, then once shown and opened again the card still closes 0.5 s after the pointer leaves")
func hidingEndsTheMenuHold() {
    // Given
    var window = expandedWindow()
    window.menuOpened()

    // When
    window.hide()
    window.pressed(at: CGPoint(x: 720, y: 850))
    window.released(at: CGPoint(x: 720, y: 850), visibleFrame: screen)
    window.pointerExited(at: second(0))
    window.check(at: second(0.5))

    // Then
    #expect(!window.isExpanded)
}

// MARK: Tucking into the edge the card is near

private let capsuleSize = FloatingWindowPlacement.capsuleSize
private let cardSize = FloatingWindowPlacement.cardSize

/// The card opened from a capsule in the middle of the screen, dragged so its bottom-left
/// corner is at `corner`, then let go.
/// - Returns: the window, and where the card was just before the button came up.
private func cardDragged(to corner: CGPoint) -> (window: FloatingWindowExpansion, cardBeforeRelease: CGRect) {
    let middle = CGPoint(x: 720, y: 450)
    var window = FloatingWindowExpansion(
        capsuleFrame: CGRect(
            x: middle.x - capsuleSize.width / 2, y: middle.y - capsuleSize.height / 2,
            width: capsuleSize.width, height: capsuleSize.height
        )
    )
    window.pressed(at: middle)
    window.released(at: middle, visibleFrame: screen)
    let start = window.frame.origin
    let grip = CGPoint(x: start.x + 20, y: start.y + 100)
    let end = CGPoint(x: grip.x + corner.x - start.x, y: grip.y + corner.y - start.y)
    window.pressed(at: grip)
    window.dragged(to: end, visibleFrame: screen)
    let cardBeforeRelease = window.frame
    window.released(at: end, visibleFrame: screen)
    return (window, cardBeforeRelease)
}

private func card(at corner: CGPoint) -> CGRect {
    CGRect(origin: corner, size: cardSize)
}

@Test("Given the card is open, when it is dragged to x 40–324, y 40–240, 40 pt from the left and bottom edges, and let go, then the card stays put and the capsule sits in its bottom-left corner")
func cardNearTheBottomLeftCornerTucksIntoIt() {
    // Given, When
    let (window, before) = cardDragged(to: CGPoint(x: 40, y: 40))

    // Then
    #expect(before == card(at: CGPoint(x: 40, y: 40)))
    #expect(window.frame == before)
    #expect(window.capsuleFrame == CGRect(x: 40, y: 40, width: capsuleSize.width, height: capsuleSize.height))
    #expect(window.isExpanded)
}

@Test("Given the card is open, when it is dragged to x 1116–1400, y 35–235, near the right and bottom edges, and let go, then the capsule sits in its bottom-right corner")
func cardNearTheBottomRightCornerTucksIntoIt() {
    // Given, When
    let (window, before) = cardDragged(to: CGPoint(x: 1116, y: 35))

    // Then
    #expect(window.frame == before)
    #expect(window.capsuleFrame == CGRect(x: 1272, y: 35, width: capsuleSize.width, height: capsuleSize.height))
}

@Test("Given the card is open, when it is dragged to x 500–784, y 300–500, near no edge, and let go, then the capsule sits in its middle")
func cardNearNoEdgeTucksIntoItsMiddle() {
    // Given, When
    let (window, before) = cardDragged(to: CGPoint(x: 500, y: 300))

    // Then
    #expect(window.frame == before)
    #expect(window.capsuleFrame == CGRect(x: 578, y: 381, width: capsuleSize.width, height: capsuleSize.height))
}

@Test("Given the card is open, when it is dragged to x 1150–1434, y 350–550, near the right edge only, and let go, then the capsule sits against its right edge, halfway up")
func cardNearOneEdgeTucksIntoItsMiddle() {
    // Given, When
    let (window, before) = cardDragged(to: CGPoint(x: 1150, y: 350))

    // Then
    #expect(window.frame == before)
    #expect(window.capsuleFrame == CGRect(x: 1306, y: 431, width: capsuleSize.width, height: capsuleSize.height))
}

@Test("Given the card is open, when it is dragged against the left and top edges, x 0–284, y 675–875, and let go, then the capsule sits in its top-left corner")
func cardAgainstTheTopLeftCornerTucksIntoIt() {
    // Given, When
    let (window, before) = cardDragged(to: CGPoint(x: 0, y: 675))

    // Then
    #expect(window.frame == before)
    #expect(window.capsuleFrame == CGRect(x: 0, y: 837, width: capsuleSize.width, height: capsuleSize.height))
}

/// How near an edge the capsule must be for the card to grow from it, across and up:
/// half of how much bigger the card is than the capsule (78 and 81 pt today).
private let nearAcross = (cardSize.width - capsuleSize.width) / 2
private let nearUp = (cardSize.height - capsuleSize.height) / 2

@Test("Given the card is open, when it is let go 1 pt nearer the left edge than a capsule grows from, and then exactly that far, then the capsule sits against its left edge the first time and in its middle the second")
func nearTheLeftEdgeEndsWhereGrowingFromItEnds() {
    // Given, When
    let (near, _) = cardDragged(to: CGPoint(x: nearAcross - 1, y: 400))
    let (far, _) = cardDragged(to: CGPoint(x: nearAcross, y: 400))

    // Then
    #expect(near.capsuleFrame.minX == near.frame.minX)
    #expect(far.capsuleFrame.midX == far.frame.midX)
}

@Test("Given the card is open, when it is let go 1 pt nearer the bottom edge than a capsule grows from, and then exactly that far, then the capsule sits against its bottom edge the first time and in its middle the second")
func nearTheBottomEdgeEndsWhereGrowingFromItEnds() {
    // Given, When
    let (near, _) = cardDragged(to: CGPoint(x: 500, y: nearUp - 1))
    let (far, _) = cardDragged(to: CGPoint(x: 500, y: nearUp))

    // Then
    #expect(near.capsuleFrame.minY == near.frame.minY)
    #expect(far.capsuleFrame.midY == far.frame.midY)
}

@Test("Given the card opened from the capsule in the top-right corner, x 1156–1440, y 675–875, when it is dragged to x 500–784, y 300–500 and let go, then the capsule sits in its middle, not its top-right corner")
func cardOpenedInACornerAndDraggedOutTucksIntoItsMiddle() {
    // Given
    var window = FloatingWindowExpansion(capsuleFrame: CGRect(x: 1312, y: 837, width: 128, height: 38))
    window.pressed(at: CGPoint(x: 1376, y: 856))
    window.released(at: CGPoint(x: 1376, y: 856), visibleFrame: screen)
    let opened = window.frame

    // When
    window.pressed(at: CGPoint(x: 1300, y: 750))
    window.dragged(to: CGPoint(x: 644, y: 375), visibleFrame: screen)
    window.released(at: CGPoint(x: 644, y: 375), visibleFrame: screen)

    // Then
    #expect(opened == CGRect(x: 1156, y: 675, width: 284, height: 200))
    #expect(window.frame == CGRect(x: 500, y: 300, width: 284, height: 200))
    #expect(window.capsuleFrame == CGRect(x: 578, y: 381, width: 128, height: 38))
}

@Test(
    "Given the card is dragged to a place and let go, when it closes and is clicked open again, then the card is back where it was let go",
    arguments: [0, 40, 77, 78, 300, 578, 1000, 1078, 1079, 1156] as [CGFloat],
    [0, 40, 80, 81, 300, 594, 595, 675] as [CGFloat]
)
func cardOpensAgainWhereItWasLetGo(x: CGFloat, y: CGFloat) {
    // Given
    var (window, before) = cardDragged(to: CGPoint(x: x, y: y))

    // When
    window.pointerExited(at: second(0))
    window.check(at: second(0.5))
    let closed = !window.isExpanded
    let middle = CGPoint(x: window.capsuleFrame.midX, y: window.capsuleFrame.midY)
    window.pointerEntered()
    window.pressed(at: middle)
    window.released(at: middle, visibleFrame: screen)

    // Then
    #expect(closed)
    #expect(window.frame == before)
}

@Test("Given the card is open, when it is clicked without moving, then the capsule stays where it was")
func clickingTheCardDoesNotTuck() {
    // Given
    var window = expandedWindow()

    // When
    window.pressed(at: CGPoint(x: 700, y: 800))
    window.released(at: CGPoint(x: 700, y: 800), visibleFrame: screen)

    // Then
    #expect(window.capsuleFrame == topCapsule)
    #expect(window.frame == CGRect(x: 578, y: 669, width: 284, height: 200))
}
