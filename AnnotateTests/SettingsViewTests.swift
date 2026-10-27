import XCTest

@testable import Annotate

@MainActor
final class SettingsViewTests: XCTestCase {
    var testDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: UserDefaults.clearDrawingsOnStartKey)
        testDefaults = UserDefaults.standard
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: UserDefaults.clearDrawingsOnStartKey)
        super.tearDown()
    }

    func testSettingsViewInitialState() {
        XCTAssertFalse(testDefaults.bool(forKey: UserDefaults.clearDrawingsOnStartKey))
    }
}
