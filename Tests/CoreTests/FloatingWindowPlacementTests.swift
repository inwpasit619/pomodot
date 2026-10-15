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
