#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class PieceTest: XCTestCase {
    func testLeafResolutions() {
        do {
            let p = Piece(sizing: .fitContent, content: .space(.zero))
            let p1 = ResolvedPiece().updated(with: p, config: .default)
            XCTAssertEqual(p1.sizing, p.sizing)
            XCTAssertEqual(p1.content.pieceFittingSize, .zero)
            let p2 = p1.layout(in: CGRect(x: 10, y: 20, width: 100, height: 200))
            XCTAssertEqual(p2.frame, CGRect(x: 10 + 50, y: 20 + 100, width: 0, height: 0))
        }
        do {
            let p = Piece(sizing: .fitContent, content: .space(CGSize(width: 10, height: 10)))
            let p1 = ResolvedPiece().updated(with: p, config: .default)
            XCTAssertEqual(p1.sizing, p.sizing)
            XCTAssertEqual(p1.content.pieceFittingSize, CGSize(width: 10, height: 10))
            let p2 = p1.layout(in: CGRect(x: 0, y: 0, width: 100, height: 100))
            XCTAssertEqual(p2.frame, CGRect(x: 45, y: 45, width: 10, height: 10))
        }
        do {
            let p = Piece(sizing: .fillContainer, content: .space(.zero))
            let p1 = ResolvedPiece().updated(with: p, config: .default)
            XCTAssertEqual(p1.sizing, p.sizing)
            XCTAssertEqual(p1.content.pieceFittingSize, .zero)
            let p2 = p1.layout(in: CGRect(x: 10, y: 20, width: 100, height: 200))
            XCTAssertEqual(p2.frame, CGRect(x: 10, y: 20, width: 100, height: 200))
        }
        do {
            let v = FixedSizedView(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
            let p = Piece(sizing: .fitContent, content: .view(v))
            let p1 = ResolvedPiece().updated(with: p, config: .default)
            XCTAssertEqual(p1.sizing, p.sizing)
            XCTAssertEqual(p1.content.pieceFittingSize, CGSize(width: 20, height: 40))
            let p2 = p1.layout(in: CGRect(x: 10, y: 20, width: 100, height: 200))
            XCTAssertEqual(p2.frame, CGRect(x: 10+50-10, y: 20+100-20, width: 20, height: 40))
        }
    }
    func testStitchResolution() {
        do {
            let p = Piece(sizing: .fitContent, content: .stitch(Stitch(version: 1, content: {
                StitchContent(axis: .horizontal, segments: [
                ])
            })))
            let p1 = ResolvedPiece().updated(with: p, config: .default)
            let p2 = p1.layout(in: CGRect(x: 10, y: 20, width: 100, height: 200))
            XCTAssertEqual(p2.frame, CGRect(x: 10 + 50, y: 20 + 100, width: 0, height: 0))
        }
        do {
            let p = Piece(sizing: .fitContent, content: .stitch(Stitch(version: 1, content: {
                StitchContent(axis: .horizontal, segments: [
                    Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 20), color: .red))),
                    Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: .zero, color: .blue))),
                ])
            })))
            let p1 = ResolvedPiece().updated(with: p, config: .default)
            let p2 = p1.layout(in: CGRect(x: 0, y: 0, width: 100, height: 200))
            XCTAssertEqual(p2.frame, CGRect(x: 50 - 5, y: 100 - 10, width: 10, height: 20))
        }
        do {
            let p = Piece(sizing: .fillContainer, content: .stitch(Stitch(version: 1, content: {
                StitchContent(axis: .horizontal, segments: [
                    Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 20), color: .red))),
                    Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: .zero, color: .blue))),
                ])
            })))
            let p1 = ResolvedPiece().updated(with: p, config: .default)
            let p2 = p1.layout(in: CGRect(x: 0, y: 0, width: 100, height: 200))
            XCTAssertEqual(p2.frame, CGRect(x: 0, y: 0, width: 100, height: 200))
            guard let x2 = p2.content.stitchSublayouts else { return XCTFail() }
            guard x2.count == 2 else { return XCTFail() }
            XCTAssertEqual(x2[0].frame, CGRect(x: 0, y: 100 - 10, width: 10, height: 20))
            XCTAssertEqual(x2[1].frame, CGRect(x: 10, y: 0, width: 90, height: 200))
        }
        do {
            let p = Piece(sizing: .fillContainer, content: .stitch(Stitch(version: 1, content: {
                StitchContent(axis: .horizontal, segments: [
                    Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 20), color: .red))),
                    Piece(sizing: .fillContainer, content: .stitch(Stitch(version: 2, content: {
                        StitchContent(axis: .vertical, segments: [
                            Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: .zero, color: .green))),
                            Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: .zero, color: .blue))),
                        ])
                    }))),
                ])
            })))
            let p1 = ResolvedPiece().updated(with: p, config: .default)
            let p2 = p1.layout(in: CGRect(x: 0, y: 0, width: 100, height: 200))
            XCTAssertEqual(p2.frame, CGRect(x: 0, y: 0, width: 100, height: 200))
            guard let x2 = p2.content.stitchSublayouts else { return XCTFail() }
            guard x2.count == 2 else { return XCTFail() }
            XCTAssertEqual(x2[0].frame, CGRect(x: 0, y: 100 - 10, width: 10, height: 20))
            XCTAssertEqual(x2[1].frame, CGRect(x: 10, y: 0, width: 90, height: 200))
            guard let x3 = x2[1].content.stitchSublayouts else { return XCTFail() }
            guard x3.count == 2 else { return XCTFail() }
            XCTAssertEqual(x3[0].frame, CGRect(x: 0, y: 0, width: 90, height: 100))
            XCTAssertEqual(x3[1].frame, CGRect(x: 0, y: 100, width: 90, height: 100))
        }
    }
    func testStack() {
        do {
            let p = Piece(sizing: .fitContent, content: .stack(Stack(version: 1, content: { [
                Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(width: 20, height: 20), color: .red))),
                Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(width: 40, height: 40), color: .green))),
                Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(width: 60, height: 60), color: .blue))),
            ]})))
            let p1 = ResolvedPiece().updated(with: p, config: .default)
            let p2 = p1.layout(in: CGRect(x: 0, y: 0, width: 100, height: 100))
            XCTAssertEqual(p2.frame, CGRect(x: 50 - 30, y: 50 - 30, width: 60, height: 60))
            guard let x2 = p2.content.stackSublayouts else { return XCTFail() }
            guard x2.count == 3 else { return XCTFail() }
            XCTAssertEqual(x2[0].frame, CGRect(x: 30 - 10, y: 30 - 10, width: 20, height: 20))
            XCTAssertEqual(x2[1].frame, CGRect(x: 30 - 20, y: 30 - 20, width: 40, height: 40))
            XCTAssertEqual(x2[2].frame, CGRect(x: 30 - 30, y: 30 - 30, width: 60, height: 60))
        }
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
