#if canImport(UIKit)
import XCTest
@testable import Patchwork

final class PieceTest: XCTestCase {
    func testText() throws {
        let x = "aaa".piece() + "bbb".piece()
        let a = x.spawn()
        XCTAssertEqual(a.string, "aaabbb")
    }
}
#endif

#if os(macOS)
#error("macOS is not supported.")
#endif
