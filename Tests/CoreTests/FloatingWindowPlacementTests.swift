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

@Test("Given the capsule is centred at (720, 850) in the top half, when it expands, then the card grows down to x 578–862, y 669–869")
func cardGrowsDownFromTheTopHalf() {
    // Given
    let capsule = capsule(centeredAt: 720, 850)

    // When
    let card = FloatingWindowPlacement.cardFrame(around: capsule, in: screen)

    // Then
    #expect(card == CGRect(x: 578, y: 669, width: 284, height: 200))
}

@Test("Given the capsule is centred at (720, 100) in the bottom half, when it expands, then the card grows up to x 578–862, y 81–281")
func cardGrowsUpFromTheBottomHalf() {
    // Given
    let capsule = capsule(centeredAt: 720, 100)

    // When
    let card = FloatingWindowPlacement.cardFrame(around: capsule, in: screen)

    // Then
    #expect(card == CGRect(x: 578, y: 81, width: 284, height: 200))
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
