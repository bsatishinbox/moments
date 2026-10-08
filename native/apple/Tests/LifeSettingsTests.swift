import XCTest
@testable import MomentModel

final class LifeSettingsTests: XCTestCase {
    let now = Date(timeIntervalSince1970: 1791374400)
    func testTargetChangeKeepsAnchor() throws {
        let original = LifeSettings.initial(now: now)
        let changed = try original.updated(age: 37, target: 70, birthday: nil, now: now.addingTimeInterval(86400))
        XCTAssertEqual(original.bornAt, changed.bornAt)
        XCTAssertEqual(changed.targetAt, LifeSettings.addingYears(70, to: original.bornAt))
    }
    func testTurningBirthdayOffCreatesAgeOnlyAnchor() throws {
        let initial = LifeSettings.initial(now: now)
        let exact = try initial.updated(age: 37, target: 60,
            birthday: initial.bornAt.addingTimeInterval(-86400 * 90), now: now)
        let changed = try exact.updated(age: exact.age(at: now), target: 60,
            birthday: nil, clearBirthday: true, now: now)
        XCTAssertFalse(changed.exactBirthday)
        XCTAssertEqual(changed.bornAt, LifeSettings.addingYears(-37, to: now))
    }
    func testWatchTargetChangePreservesExactBirthday() throws {
        let initial = LifeSettings.initial(now: now)
        let exact = try initial.updated(age: 37, target: 60,
            birthday: initial.bornAt.addingTimeInterval(-86400 * 90), now: now)
        let changed = try exact.updated(age: exact.age(at: now), target: 70,
            birthday: nil, now: now)
        XCTAssertTrue(changed.exactBirthday)
        XCTAssertEqual(changed.bornAt, exact.bornAt)
    }
    func testExpiredCountdownClampsToZero() {
        let value = LifeSettings.initial(now: now)
        XCTAssertEqual(value.total(.minutes, at: value.targetAt.addingTimeInterval(1)), 0)
        XCTAssertEqual(value.fraction(at: value.targetAt.addingTimeInterval(1)), 0)
    }
    func testInvalidTargetIsRejected() {
        let value = LifeSettings.initial(now: now)
        XCTAssertThrowsError(try value.updated(age: 37, target: 36, birthday: nil, now: now))
    }
    func testEncodingPreservesAnchor() throws {
        let value = LifeSettings.initial(now: now)
        let restored = try JSONDecoder().decode(LifeSettings.self, from: JSONEncoder().encode(value))
        XCTAssertEqual(value, restored)
    }
}
