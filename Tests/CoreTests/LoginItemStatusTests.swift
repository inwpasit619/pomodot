import Testing
import Core

@Test("Given macOS says Pomodot opens at login, when Settings shows Open at login, then the switch is on with no warning")
func enabledLoginItemIsOn() {
    // Given
    let status = LoginItemStatus.enabled

    // When
    let isOn = status.isOn
    let warns = status.needsApproval

    // Then
    #expect(isOn)
    #expect(!warns)
}

@Test("Given macOS says Pomodot isn't registered, or has never been, when Settings shows Open at login, then the switch is off with no warning")
func unregisteredLoginItemIsOff() {
    // Given
    let statuses: [LoginItemStatus] = [.notRegistered, .notFound]

    // When
    let switches = statuses.map(\.isOn)
    let warnings = statuses.map(\.needsApproval)

    // Then
    #expect(switches == [false, false])
    #expect(warnings == [false, false])
}

@Test("Given macOS wants the user's approval, when Settings shows Open at login, then the switch is on and the orange warning shows")
func loginItemNeedingApprovalIsOnAndWarns() {
    // Given
    let status = LoginItemStatus.requiresApproval

    // When
    let isOn = status.isOn
    let warns = status.needsApproval

    // Then
    #expect(isOn)
    #expect(warns)
}
