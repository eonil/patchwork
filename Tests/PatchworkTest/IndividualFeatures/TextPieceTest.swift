#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class TextPieceTest: XCTestCase {
    func testText() {
        let v = PieceView()
        v.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
        v.backgroundColor = .white
        v.piece = fit {
            text("AAAA AAAA".attributedWithDefaultFont())
        }
        assertSnapshot(matching: v, as: .image)
    }
    func test3Rows() {
        let v = PieceView()
        let p = fitX {
            divY {
                divX {
                    text("AAAA AAAA".attributedWithDefaultFont())
                    text("AAAA AAAA".attributedWithDefaultFont())
                }
                fitSpace(width: 0, height: 4)
                divX {
                    text("AAAA AAAA".attributedWithDefaultFont())
                    text("AAAA AAAA".attributedWithDefaultFont())
                }
                fitSpace(width: 0, height: 4)
                divX {
                    text("AAAA AAAA".attributedWithDefaultFont())
                    text("AAAA AAAA".attributedWithDefaultFont())
                }
            }
        }
        v.piece = p
        v.backgroundColor = .white
        v.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
        assertSnapshot(matching: v, as: .image)
    }
}

private extension String {
    func attributedWithDefaultFont() -> NSAttributedString {
        NSAttributedString(string: self, attributes: [
            .font: UIFont.systemFont(ofSize: UIFont.systemFontSize)
        ])
    }
}

private final class FixedSizedView: UIView {
    override func sizeThatFits(_ size: CGSize) -> CGSize { frame.size }
}
private extension RenderingPieceContent {
    var stitchSublayouts: [RenderingPieceLayout]? {
        guard case let .stitch(horizontal) = self else { return nil }
        return horizontal
    }
    var stackSublayouts: [RenderingPieceLayout]? {
        guard case let .stack(horizontal) = self else { return nil }
        return horizontal
    }
}

#endif
