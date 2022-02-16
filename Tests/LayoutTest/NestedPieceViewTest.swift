#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class NestedPieceViewTest: XCTestCase {
    func test1() {
        let a = PieceView()
        let b = PieceView()
        /// `b` need to be laid out first to provide correct size.
        /// `a` does not re-scan `b` for new size.
        b.piece = Piece(
            horizontal: .fitContent,
            vertical: .fitContent,
            content: .color(ColorPieceContent(size: CGSize(width: 100, height: 20), color: .red)))
        
        a.backgroundColor = .gray
        a.piece = divY {
            spaceY(8)
            Piece(horizontal: .fillContainer, vertical: .fitContent, content: .view(b))
            fill { color(.blue) }
        }
        a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        assertSnapshot(matching: a, as: .image)
    }
}

private func spaceY(_ k:CGFloat) -> Piece {
    Piece(horizontal: .fitContent, vertical: .fitContent, content: .space(CGSize(width: 0, height: k)))
}

private final class FixedSizedView: UIView {
    override func sizeThatFits(_ size: CGSize) -> CGSize { frame.size }
}
#endif
