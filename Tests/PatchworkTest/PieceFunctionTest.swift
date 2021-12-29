#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class PieceFunctionTest: XCTestCase {
    func testHappyCase() {
        do {
            let a = PieceView()
            let b = color(.white, horizontal: 20, vertical: 40)
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(horizontal: 0, vertical: 0, horizontal: 100, vertical: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = divX {
                color(.red, horizontal: 10, vertical: 10)
                color(.green, horizontal: 10, vertical: 10)
                color(.blue, horizontal: 10, vertical: 10)
            }
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(horizontal: 0, vertical: 0, horizontal: 100, vertical: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = divX {
                color(.red)
                color(.green)
                color(.blue)
            }
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(horizontal: 0, vertical: 0, horizontal: 100, vertical: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = divX {
                color(.red, horizontal: 10, vertical: 10)
                divX {
                    space()
                    color(.green)
                    color(.blue)
                }
            }
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(horizontal: 0, vertical: 0, horizontal: 100, vertical: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = stackZ {
                color(.red.withAlphaComponent(0.5), horizontal: 20, vertical: 20)
                color(.green.withAlphaComponent(0.5), horizontal: 40, vertical: 40)
                color(.blue.withAlphaComponent(0.5), horizontal: 60, vertical: 60)
            }
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(horizontal: 0, vertical: 0, horizontal: 100, vertical: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = divX {
                color(.gray, horizontal: 5, vertical: 10)
                wrapY {
                    color(.red, horizontal: 30, vertical: 20)
                    color(.green, horizontal: 30, vertical: 20)
                }
                color(.gray)
                wrapY {
                    color(.blue, horizontal: 10, vertical: 20)
                    color(.red, horizontal: 10, vertical: 20)
                }
                color(.gray)
                wrapY {
                    color(.blue, horizontal: 10, vertical: 20)
                    color(.red, horizontal: 10, vertical: 20)
                }
                color(.gray, horizontal: 5, vertical: 10)
            }
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(horizontal: 0, vertical: 0, horizontal: 100, vertical: 100)
            assertSnapshot(matching: a, as: .image)
        }
    }
    func testSimpleForm() {
        let a = PieceView()
        let b = divY {
            space()
            divX(vertical: .fitContent) {
                space(horizontal: 0, vertical: 20)
                stackZ {
                    color(.red.withAlphaComponent(0.1))
                    divX {
                        space()
                        wrapY {
                            text(NSAttributedString(string: "AAA", attributes: [
                                .font: UIFont.systemFont(ofSize: 8),
                                .foregroundColor: UIColor.white,
                            ]))
                            text(NSAttributedString(string: "AAA", attributes: [
                                .font: UIFont.systemFont(ofSize: 8),
                                .foregroundColor: UIColor.white,
                            ]))
                        }
                        space(horizontal: 10, vertical: 0)
                    }
                }
            }
            divX(vertical: .fitContent) {
                space(horizontal: 0, vertical: 20)
                stackZ {
                    color(.red.withAlphaComponent(0.2))
                    text(NSAttributedString(string: "AAA", attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
                }
            }
            divX(vertical: .fitContent) {
                space(horizontal: 0, vertical: 20)
                stackZ {
                    color(.red.withAlphaComponent(0.3))
                    text(NSAttributedString(string: "AAA", attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
                }
            }
            divX(vertical: .fitContent) {
                space(horizontal: 0, vertical: 20)
                stackZ {
                    color(.red.withAlphaComponent(0.4))
                    text(NSAttributedString(string: "AAA", attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
                }
            }
        }
        a.backgroundColor = .black
        a.piece = b
        a.frame = CGRect(horizontal: 0, vertical: 0, horizontal: 100, vertical: 100)
        assertSnapshot(matching: a, as: .image)
    }
}

#endif
