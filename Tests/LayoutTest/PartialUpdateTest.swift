#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class PartialUpdateTest: XCTestCase {
    func test1() {
        let p = PieceView()
        p.backgroundColor = .gray
        p.piece = divY {
            spaceY(8)
            fillX {
                Piece(
                    horizontal: .fitContent,
                    vertical: .fitContent,
                    content: .color(ColorPieceContent(size: CGSize(width: 100, height: 20), color: .red)))
            }
            fill { color(.blue) }
        }
        
        p.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        assertSnapshot(matching: p, as: .image)
        
        p.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        assertSnapshot(matching: p, as: .image)
    }
}

private func spaceY(_ k:CGFloat) -> Piece {
    Piece(horizontal: .fitContent, vertical: .fitContent, content: .space(CGSize(width: 0, height: k)))
}

private final class FixedSizedView: UIView {
    override func sizeThatFits(_ size: CGSize) -> CGSize { frame.size }
}
#endif
