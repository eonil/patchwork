#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class PieceFunctionTest: XCTestCase {
    
    func testPassingPieceArrayAsContent() {
        func testDiv(@ArrayBuilder<Piece> content: @escaping() -> [Piece]) -> Piece {
            divX(content: { content() })
        }
    }
    
    func testHappyCase() {
        do {
            let a = PieceView()
            let b = fitColor(.white, width: 20, height: 40)
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = divX {
                fitColor(.red, width: 10, height: 10)
                fitColor(.green, width: 10, height: 10)
                fitColor(.blue, width: 10, height: 10)
            }
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
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
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = divX {
                fitColor(.red, width: 10, height: 10)
                divX {
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
                fitColor(.red.withAlphaComponent(0.5), width: 20, height: 20)
                fitColor(.green.withAlphaComponent(0.5), width: 40, height: 40)
                fitColor(.blue.withAlphaComponent(0.5), width: 60, height: 60)
            }
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = divX {
                fitColor(.gray, width: 5, height: 10)
                fitX {
                    divY {
                        fitColor(.red, width: 30, height: 20)
                        fitColor(.green, width: 30, height: 20)
                    }
                }
                color(.gray)
                fitX {
                    divY {
                        fitColor(.blue, width: 10, height: 20)
                        fitColor(.red, width: 10, height: 20)
                    }
                }
                color(.gray)
                fitX {
                    divY {
                        fitColor(.blue, width: 10, height: 20)
                        fitColor(.red, width: 10, height: 20)
                    }
                }
                fitColor(.gray, width: 5, height: 10)
            }
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
    }
    func testSimpleForm1() {
        let a = PieceView()
        let b = divY {
            space()
            divX(vertical: .fitContent) {
                fitSpace(width: 0, height: 20)
                stackZ {
                    color(.red.withAlphaComponent(0.1))
                    divX {
                        space()
                        fit {
                            divY {
                                text(NSAttributedString(string: "AAA", attributes: [
                                    .font: UIFont.systemFont(ofSize: 8),
                                    .foregroundColor: UIColor.white,
                                ]))
                                text(NSAttributedString(string: "AAA", attributes: [
                                    .font: UIFont.systemFont(ofSize: 8),
                                    .foregroundColor: UIColor.white,
                                ]))
                            }
                        }
                        fitSpace(width: 10, height: 0)
                    }
                }
            }
            divX(vertical: .fitContent) {
                fitSpace(width: 0, height: 20)
                stackZ {
                    color(.red.withAlphaComponent(0.2))
                    text(NSAttributedString(string: "AAA", attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
                }
            }
            divX(vertical: .fitContent) {
                fitSpace(width: 0, height: 20)
                stackZ {
                    color(.red.withAlphaComponent(0.3))
                    text(NSAttributedString(string: "AAA", attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
                }
            }
            divX(vertical: .fitContent) {
                fitSpace(width: 0, height: 20)
                stackZ {
                    color(.red.withAlphaComponent(0.4))
                    text(NSAttributedString(string: "AAA", attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
                }
            }
        }
        a.backgroundColor = .black
        a.piece = b
        a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        assertSnapshot(matching: a, as: .image)
    }
    /// Stacking from top.
    func testSimpleForm2() {
        let a = PieceView()
        let b = divY {
            divX(vertical: .fitContent) {
                fitSpace(width: 0, height: 20)
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
                        fitSpace(width: 10, height: 0)
                    }
                }
            }
            space()
        }
        a.backgroundColor = .black
        a.piece = b
        a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        assertSnapshot(matching: a, as: .image)
    }
    func testSimpleForm3() {
        let a = PieceView()
        let b = divY {
            fitY {
                stackZ {
                    color(.gray)
                    divY {
                        divX {
                            space()
                            fit {
                                text(makeAttributedText("AAA", .white))
                            }
                            space()
                        }
                        stackZ {
                            fitSpace(width: 1, height: 1)
                            color(.black)
                        }
                        divX {
                            space()
                            fit {
                                text(makeAttributedText("AAA", .white))
                            }
                            space()
                        }
                    }
                }
            }
            space()
        }
        
        a.backgroundColor = .black
        a.piece = b
        a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        assertSnapshot(matching: a, as: .image)
    }
    
    /// This produces output that looks weird, but it's correct.
    /// - `fitY` does not fit in X axis.
    /// - Therefore, top-level children `fitY`, `color`, and `fitY` are all `.fillContainer` in X axis.
    /// - Therefore, they will be stretched proportionally.
    /// - `color` does not have defined minimum fitting size. Therefore zero sized by default.
    /// - `fitY` and `fitY` yields `30` and `10` minimum fitting size.
    /// - Therefore two `fitY` children takes all available area in X axis.
    /// - As there are pieces with non-zero widths, top-level `color` piece can't take any space, becomes invisible.
    /// - Leaf-level red, green, blue color pieces have defined sizes, therefore won't be stretched.
    func testCase7() {
        let a = PieceView()
        let b = divX {
            fitY {
                divY {
                    fitColor(.red, width: 30, height: 20)
                    fitColor(.green, width: 30, height: 20)
                }
            }
            color(.gray)
            fitY {
                divY {
                    fitColor(.blue, width: 10, height: 20)
                    fitColor(.red, width: 10, height: 20)
                }
            }
        }
        a.backgroundColor = .black
        a.piece = b
        a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        assertSnapshot(matching: a, as: .image)
    }
}

private func makeAttributedText(_ s:String, _ c:UIColor) -> NSAttributedString {
    NSAttributedString(string: s, attributes: [
        .font: UIFont.systemFont(ofSize: 8),
        .foregroundColor: c,
    ])
}

#endif
