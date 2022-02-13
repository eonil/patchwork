#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class PieceSnapshotTest: XCTestCase {
    func testEmbeddedView() {
        let a = PieceView()
        let b = FixedSizedView()
        let c = FixedSizedView()
        a.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        a.backgroundColor = .gray
        b.frame.size = CGSize(width: 10, height: 10)
        b.backgroundColor = .red
        c.frame.size = CGSize(width: 10, height: 10)
        c.backgroundColor = .blue
        
        a.piece = Piece(horizontal: .fitContent, vertical: .fitContent, content: .view(b))
        assertSnapshot(matching: a, as: .image)
        
        a.piece = Piece(horizontal: .fitContent, vertical: .fitContent, content: .view(c))
        assertSnapshot(matching: a, as: .image)
    }
}

private final class FixedSizedView: UIView {
    override func sizeThatFits(_ size: CGSize) -> CGSize { frame.size }
}
#endif
