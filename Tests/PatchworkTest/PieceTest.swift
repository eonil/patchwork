#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class PieceTest: XCTestCase {
    func testText() throws {
        let x = "aaa".piece() + "bbb".piece()
        let a = x.spawn()
        guard a.string == "aaabbb" else { return XCTFail() }
    }
    func testImage() throws {
        let m = UIImage()
        let a = Image(content: m)
        let b = PieceView(with: a)
        guard b.subviews.count == 1 else { return XCTFail() }
        guard let c = b.subviews[0] as? UIImageView else { return XCTFail() }
        guard c.image === m else { return XCTFail() }
    }
    func testStack() throws {
        let a = Stack(axis: .vertical, subpieces: [
            Color(content: .red),
            Text(content: ["AAA".piece()]),
        ])
        let b = PieceView(with: a)
        guard b.subviews.count == 1 else { return XCTFail() }
        guard let c = b.subviews.first as? UIStackView else { return XCTFail() }
        guard c.subviews.count == 2 else { return XCTFail() }
        guard let c1 = c.subviews[0] as? PieceColorView else { return XCTFail() }
        guard let c2 = c.subviews[1] as? PieceTextView else { return XCTFail() }
        guard c1.backgroundColor == UIColor.red else { return XCTFail() }
        guard c2.attributedText?.string == "AAA" else { return XCTFail() }
        b.frame.size = b.systemLayoutSizeFitting(.zero)
        assertSnapshot(matching: b, as: .image)
    }
    func testNestedStack() throws {
        let a = Stack(axis: .vertical, subpieces: [
            Color(content: .red),
            Stack(axis: .horizontal, subpieces: [
                Text(content: ["AAA".piece()]),
            ])
        ])
        let b = PieceView(with: a)
        guard b.subviews.count == 1 else { return XCTFail() }
        guard let c = b.subviews.first as? PieceStackView else { return XCTFail() }
        guard c.subviews.count == 2 else { return XCTFail() }
        guard let c1 = c.subviews[0] as? PieceColorView else { return XCTFail() }
        guard let c2 = c.subviews[1] as? PieceStackView else { return XCTFail() }
        guard c1.backgroundColor == UIColor.red else { return XCTFail() }
        guard c2.subviews.count == 1 else { return XCTFail() }
        guard b.sizeThatFits(.zero) == .zero else { return XCTFail() }
    }
    func testFixedSizedStack() throws {
        let spec = Stack(axis: .horizontal, subpieces: [
            Space(id: "AAA", layout: Layout(defaultWidth: 10, defaultHeight: 20)),
            Space(id: "BBB", layout: Layout(defaultWidth: 100, defaultHeight: 200)),
        ])
        let view = PieceView(with: spec)
        guard view.systemLayoutSizeFitting(.zero) == .init(width: 110, height: 200) else { return XCTFail() }
        guard view.subviews.count == 1 else { return XCTFail() }
        guard let x = view.subviews[0] as? PieceStackView else { return XCTFail() }
        guard x.axis == .horizontal else { return XCTFail() }
        guard x.subviews.count == 2 else { return XCTFail() }
        guard let x1 = x.subviews[0] as? PieceSpaceView else { return XCTFail() }
        guard let x2 = x.subviews[1] as? PieceSpaceView else { return XCTFail() }
        guard x1.piece.id == AnyHashable("AAA") else { return XCTFail() }
        guard x2.piece.id == AnyHashable("BBB") else { return XCTFail() }
    }
}
#endif

#if os(macOS)
#error("macOS is not supported.")
#endif
