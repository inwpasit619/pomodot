import CoreGraphics
import Testing
import Core

@Test("Given the main display's usable area is (0, 0)–(1440, 875), when no Floating Window position is remembered, then the capsule is centred at x = 720 with its top edge at y = 863")
func startingPositionIsTopCentreBelowMenuBar() {
    // Given
    let visibleFrame = CGRect(x: 0, y: 0, width: 1440, height: 875)

    // When
    let capsule = FloatingWindowPlacement.startingCapsuleFrame(in: visibleFrame)

    // Then
    #expect(capsule.midX == 720)
    #expect(capsule.maxY == 863)
}

/// The usable area from the spec's examples, and a capsule centred on (x, y).
private let screen = CGRect(x: 0, y: 0, width: 1440, height: 875)
private func capsule(centeredAt x: CGFloat, _ y: CGFloat) -> CGRect {
    CGRect(x: x - 64, y: y - 19, width: 128, height: 38)
}

@Test("Given the capsule is centred at (720, 850) near the top edge, when it expands, then the card grows down to x 578–862, y 669–869")
func cardGrowsDownNearTheTopEdge() {
    // Given
    let capsule = capsule(centeredAt: 720, 850)

    // When
    let card = FloatingWindowPlacement.cardFrame(around: capsule, in: screen)

    // Then
    #expect(card == CGRect(x: 578, y: 669, width: 284, height: 200))
}

@Test("Given the capsule is centred at (720, 60) near the bottom edge, when it expands, then the card grows up to x 578–862, y 41–241")
func cardGrowsUpNearTheBottomEdge() {
    // Given
    let capsule = capsule(centeredAt: 720, 60)

    // When
    let card = FloatingWindowPlacement.cardFrame(around: capsule, in: screen)

    // Then
    #expect(card == CGRect(x: 578, y: 41, width: 284, height: 200))
}

@Test("Given the capsule is centred at (720, 450), away from every edge, when it expands, then the card grows out from its middle to x 578–862, y 350–550")
func cardGrowsFromTheMiddleAwayFromTheEdges() {
    // Given
    let capsule = capsule(centeredAt: 720, 450)

    // When
    let card = FloatingWindowPlacement.cardFrame(around: capsule, in: screen)

    // Then
    #expect(card == CGRect(x: 578, y: 350, width: 284, height: 200))
}

@Test("Given the capsule is centred at (1370, 850) near the right edge, when it expands, then the card lines up with the capsule's right edge at x 1150–1434")
func cardLinesUpWithTheCapsuleNearTheRightEdge() {
    // Given
    let capsule = capsule(centeredAt: 1370, 850)

    // When
    let card = FloatingWindowPlacement.cardFrame(around: capsule, in: screen)

    // Then
    #expect(card == CGRect(x: 1150, y: 669, width: 284, height: 200))
}

@Test("Given the capsule is centred at (70, 850) near the left edge, when it expands, then the card lines up with the capsule's left edge at x 6–290")
func cardLinesUpWithTheCapsuleNearTheLeftEdge() {
    // Given
    let capsule = capsule(centeredAt: 70, 850)

    // When
    let card = FloatingWindowPlacement.cardFrame(around: capsule, in: screen)

    // Then
    #expect(card == CGRect(x: 6, y: 669, width: 284, height: 200))
}

@Test("Given the remembered capsule centre (2000, 500) is on no display's usable area, when the app opens, then the capsule goes back to the starting position, centred at x = 720 with its top edge at y = 863")
func aRememberedPositionOffEveryDisplayGoesBackToTheStart() {
    // Given
    let remembered = CGPoint(x: 2000, y: 500)

    // When
    let capsule = FloatingWindowPlacement.capsuleFrame(remembering: remembered, screens: [screen], mainScreen: screen)

    // Then
    #expect(capsule.midX == 720)
    #expect(capsule.maxY == 863)
}

@Test("Given the remembered capsule centre (300, 400) is on a display, when the app opens, then the capsule is centred there")
func aRememberedPositionOnADisplayIsUsed() {
    // Given
    let remembered = CGPoint(x: 300, y: 400)

    // When
    let capsule = FloatingWindowPlacement.capsuleFrame(remembering: remembered, screens: [screen], mainScreen: screen)

    // Then
    #expect(capsule == CGRect(x: 236, y: 381, width: 128, height: 38))
}

// MARK: The card's menu

@Test("Given the ellipsis button at x 820–842, y 500–522 and a 280 pt menu, when the menu opens, then its top-left corner is at (820, 496), just below the button")
func menuOpensBelowTheEllipsisButton() {
    // Given
    let button = CGRect(x: 820, y: 500, width: 22, height: 22)

    // When
    let corner = FloatingWindowPlacement.menuCorner(below: button, menuHeight: 280, in: screen)

    // Then
    #expect(corner == CGPoint(x: 820, y: 496))
}

@Test("Given the ellipsis button at x 820–842, y 200–222 near the bottom edge and a 280 pt menu, when the menu opens, then it opens above the button with its top-left corner at (820, 506)")
func menuOpensAboveTheEllipsisButtonWithoutRoomBelow() {
    // Given
    let button = CGRect(x: 820, y: 200, width: 22, height: 22)

    // When
    let corner = FloatingWindowPlacement.menuCorner(below: button, menuHeight: 280, in: screen)

    // Then
    #expect(corner == CGPoint(x: 820, y: 506))
}

@Test("Given the ellipsis button at x 820–842, y 284–306 and a 280 pt menu, when the menu opens, then it just fits below, its bottom on the usable area's bottom edge")
func menuThatJustFitsOpensBelow() {
    // Given
    let button = CGRect(x: 820, y: 284, width: 22, height: 22)

    // When
    let corner = FloatingWindowPlacement.menuCorner(below: button, menuHeight: 280, in: screen)

    // Then
    #expect(corner == CGPoint(x: 820, y: 280))
}
