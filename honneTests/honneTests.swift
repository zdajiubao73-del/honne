import XCTest
@testable import honne

final class honneTests: XCTestCase {

    // MARK: - SafetyFilter Tests（#004 で本格実装）

    func testSafetyFilterLevel2Detection() throws {
        // TODO: #004 でセーフガード統合後に実装
        // let result = SafetyFilter.check("死にたい")
        // XCTAssertEqual(result, .level2)
    }

    func testSafetyFilterLevel1Detection() throws {
        // TODO: #004 でセーフガード統合後に実装
        // let result = SafetyFilter.check("消えたい")
        // XCTAssertEqual(result, .level1)
    }

    func testSafetyFilterClean() throws {
        // TODO: #004 でセーフガード統合後に実装
        // let result = SafetyFilter.check("今日仕事がつらかった")
        // XCTAssertEqual(result, .safe)
    }
}
