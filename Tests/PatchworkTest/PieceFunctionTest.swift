#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class PieceFunctionTest: XCTestCase {
    func testHappyCase() {
        do {
            let a = PieceView()
            let b = color(.white, width: 20, height: 40)
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = stitchX {
                color(.red, width: 10, height: 10)
                color(.green, width: 10, height: 10)
                color(.blue, width: 10, height: 10)
            }
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = stitchX {
                color(.red)
                color(.green)
                color(.blue)
            }
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = stitchX {
                color(.red, width: 10, height: 10)
                stitchX {
                    space()
                    color(.green)
                    color(.blue)
                }
            }
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = stackZ {
                color(.red.withAlphaComponent(0.5), width: 20, height: 20)
                color(.green.withAlphaComponent(0.5), width: 40, height: 40)
                color(.blue.withAlphaComponent(0.5), width: 60, height: 60)
            }
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
    }
}

#endif
