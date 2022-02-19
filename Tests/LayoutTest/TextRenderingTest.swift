#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork


final class TextRenderingTest: XCTestCase {
    func test1() {
        let a = PieceView()
        a.config = .pointGridFitting
        a.piece = makeDoublePiece(depth: 4) /// 256 texts + branch pieces.
        a.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        a.layoutIfNeeded()
        assertSnapshot(matching: a, as: .image)
        a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        a.layoutIfNeeded()
        assertSnapshot(matching: a, as: .image)
    }
}

private final class FixedSizedView: UIView {
    override func sizeThatFits(_ size: CGSize) -> CGSize { frame.size }
}

private var seed = 0
private func makeDoublePiece(depth n:Int) -> Piece {
    assert(n >= 0)
    if n == 0 {
        seed += 1
        return text("\(seed)")
    }
    else {
        return divX {
            divY {
                makeDoublePiece(depth: n - 1)
                makeDoublePiece(depth: n - 1)
            }
            divY {
                makeDoublePiece(depth: n - 1)
                makeDoublePiece(depth: n - 1)
            }
        }
    }
}

private func divX(@ArrayBuilder<Piece> contents: () -> [Piece]) -> Piece {
    let ps = contents()
    return Piece(
        horizontal: .fillContainer,
        vertical: .fillContainer,
        content: .stitch(Stitch(
            version: AlwaysDifferent(),
            content: {
                StitchContent(axis: .horizontal, segments: ps)
            })))
}
private func divY(@ArrayBuilder<Piece> contents: () -> [Piece]) -> Piece {
    let ps = contents()
    return Piece(
        horizontal: .fillContainer,
        vertical: .fillContainer,
        content: .stitch(Stitch(
            version: AlwaysDifferent(),
            content: {
                StitchContent(axis: .vertical, segments: ps)
            })))
}
private func text(_ s:String) -> Piece {
    Piece(horizontal: .fitContent, vertical: .fitContent, content: .text(makeAttributedText(s, .red)))
}
private func makeAttributedText(_ s:String, _ c:UIColor) -> NSAttributedString {
    NSAttributedString(string: s, attributes: [
        .font: UIFont.systemFont(ofSize: 6),
        .foregroundColor: c,
    ])
}
#endif
