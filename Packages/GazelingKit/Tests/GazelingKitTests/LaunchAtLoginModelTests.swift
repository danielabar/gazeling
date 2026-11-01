import Testing

@testable import GazelingKit

@MainActor
private final class FakeLaunchAtLogin: LaunchAtLogin {
    var status: LaunchAtLoginStatus = .off
    /// What `register()` makes the status become (macOS may want approval first).
    var statusAfterRegister: LaunchAtLoginStatus = .on
    var registerError: Error?
    var registerCalls = 0
    var unregisterCalls = 0
    var openSettingsCalls = 0

    func register() throws {
        registerCalls += 1
        if let registerError { throw registerError }
        status = statusAfterRegister
    }

    func unregister() throws {
        unregisterCalls += 1
        status = .off
    }

    func openSystemSettings() { openSettingsCalls += 1 }
}

private struct TestError: Error {}

@Test @MainActor func startsWithTheAdapterStatus() {
    let fake = FakeLaunchAtLogin()
    fake.status = .on
    #expect(LaunchAtLoginModel(adapter: fake).status == .on)
}

@Test @MainActor func turningOnRegistersAndShowsTheNewStatus() {
    let fake = FakeLaunchAtLogin()
    let model = LaunchAtLoginModel(adapter: fake)
    model.setEnabled(true)
    #expect(fake.registerCalls == 1)
    #expect(model.status == .on)
    #expect(model.errorMessage == nil)
}

@Test @MainActor func turningOffUnregisters() {
    let fake = FakeLaunchAtLogin()
    fake.status = .on
    let model = LaunchAtLoginModel(adapter: fake)
    model.setEnabled(false)
    #expect(fake.unregisterCalls == 1)
    #expect(model.status == .off)
}

@Test @MainActor func turningOnWhenAlreadyOnDoesNotRegisterAgain() {
    let fake = FakeLaunchAtLogin()
    fake.status = .on
    let model = LaunchAtLoginModel(adapter: fake)
    model.setEnabled(true)
    #expect(fake.registerCalls == 0)
}

@Test @MainActor func aFailedRegisterShowsAnErrorAndStaysOff() {
    let fake = FakeLaunchAtLogin()
    fake.registerError = TestError()
    let model = LaunchAtLoginModel(adapter: fake)
    model.setEnabled(true)
    #expect(model.errorMessage != nil)
    #expect(model.status == .off)
}

@Test @MainActor func aLaterSuccessClearsTheError() {
    let fake = FakeLaunchAtLogin()
    fake.registerError = TestError()
    let model = LaunchAtLoginModel(adapter: fake)
    model.setEnabled(true)
    fake.registerError = nil
    model.setEnabled(true)
    #expect(model.errorMessage == nil)
    #expect(model.status == .on)
}

@Test @MainActor func refreshPicksUpAChangeMadeInSystemSettings() {
    let fake = FakeLaunchAtLogin()
    fake.status = .on
    let model = LaunchAtLoginModel(adapter: fake)
    fake.status = .off
    model.refresh()
    #expect(model.status == .off)
}

@Test @MainActor func waitingForApprovalCountsAsOnButNeedsApproval() {
    let fake = FakeLaunchAtLogin()
    fake.statusAfterRegister = .requiresApproval
    let model = LaunchAtLoginModel(adapter: fake)
    model.setEnabled(true)
    #expect(model.status == .requiresApproval)
    #expect(model.isOn)
    #expect(model.needsApproval)
}

@Test @MainActor func onAndOffReportTheToggleState() {
    let fake = FakeLaunchAtLogin()
    let model = LaunchAtLoginModel(adapter: fake)
    #expect(!model.isOn)
    #expect(!model.needsApproval)
    fake.status = .on
    model.refresh()
    #expect(model.isOn)
    #expect(!model.needsApproval)
}

@Test @MainActor func openSystemSettingsReachesTheAdapter() {
    let fake = FakeLaunchAtLogin()
    LaunchAtLoginModel(adapter: fake).openSystemSettings()
    #expect(fake.openSettingsCalls == 1)
}
