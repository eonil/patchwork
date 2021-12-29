#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class PieceTest: XCTestCase {
    func testLeafResolutions() {
        do {
            let p = Piece(sizing: .fitContent, content: .space(.zero))
            let p1 = ResolvedPiece(from: p)
            XCTAssertEqual(p1.sizing, p.sizing)
            XCTAssertEqual(p1.content.fittingSize, .zero)
            let p2 = p1.layout(in: CGRect(horizontal: 10, vertical: 20, horizontal: 100, vertical: 200))
            XCTAssertEqual(p2.frame, CGRect(horizontal: 10 + 50, vertical: 20 + 100, horizontal: 0, vertical: 0))
        }
        do {
            let p = Piece(sizing: .fitContent, content: .space(CGSize(horizontal: 10, vertical: 10)))
            let p1 = ResolvedPiece(from: p)
            XCTAssertEqual(p1.sizing, p.sizing)
            XCTAssertEqual(p1.content.fittingSize, CGSize(horizontal: 10, vertical: 10))
            let p2 = p1.layout(in: CGRect(horizontal: 0, vertical: 0, horizontal: 100, vertical: 100))
            XCTAssertEqual(p2.frame, CGRect(horizontal: 45, vertical: 45, horizontal: 10, vertical: 10))
        }
        do {
            let p = Piece(sizing: .fillContainer, content: .space(.zero))
            let p1 = ResolvedPiece(from: p)
            XCTAssertEqual(p1.sizing, p.sizing)
            XCTAssertEqual(p1.content.fittingSize, .zero)
            let p2 = p1.layout(in: CGRect(horizontal: 10, vertical: 20, horizontal: 100, vertical: 200))
            XCTAssertEqual(p2.frame, CGRect(horizontal: 10, vertical: 20, horizontal: 100, vertical: 200))
        }
        do {
            let v = FixedSizedView(frame: CGRect(horizontal: 0, vertical: 0, horizontal: 20, vertical: 40))
            let p = Piece(sizing: .fitContent, content: .view(v))
            let p1 = ResolvedPiece(from: p)
            XCTAssertEqual(p1.sizing, p.sizing)
            XCTAssertEqual(p1.content.fittingSize, CGSize(horizontal: 20, vertical: 40))
            let p2 = p1.layout(in: CGRect(horizontal: 10, vertical: 20, horizontal: 100, vertical: 200))
            XCTAssertEqual(p2.frame, CGRect(horizontal: 10+50-10, vertical: 20+100-20, horizontal: 20, vertical: 40))
        }
    }
    func testStitchResolution() {
        do {
            let p = Piece(sizing: .fitContent, content: .stitch(Stitch(version: 1, content: {
                StitchContent(axis: .horizontal, segments: [
                ])
            })))
            let p1 = ResolvedPiece(from: p)
            let p2 = p1.layout(in: CGRect(horizontal: 10, vertical: 20, horizontal: 100, vertical: 200))
            XCTAssertEqual(p2.frame, CGRect(horizontal: 10 + 50, vertical: 20 + 100, horizontal: 0, vertical: 0))
        }
        do {
            let p = Piece(sizing: .fitContent, content: .stitch(Stitch(version: 1, content: {
                StitchContent(axis: .horizontal, segments: [
                    Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(horizontal: 10, vertical: 20), color: .red))),
                    Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: .zero, color: .blue))),
                ])
            })))
            let p1 = ResolvedPiece(from: p)
            let p2 = p1.layout(in: CGRect(horizontal: 0, vertical: 0, horizontal: 100, vertical: 200))
            XCTAssertEqual(p2.frame, CGRect(horizontal: 50 - 5, vertical: 100 - 10, horizontal: 10, vertical: 20))
        }
        do {
            let p = Piece(sizing: .fillContainer, content: .stitch(Stitch(version: 1, content: {
                StitchContent(axis: .horizontal, segments: [
                    Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(horizontal: 10, vertical: 20), color: .red))),
                    Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: .zero, color: .blue))),
                ])
            })))
            let p1 = ResolvedPiece(from: p)
            let p2 = p1.layout(in: CGRect(horizontal: 0, vertical: 0, horizontal: 100, vertical: 200))
            XCTAssertEqual(p2.frame, CGRect(horizontal: 0, vertical: 0, horizontal: 100, vertical: 200))
            guard let x2 = p2.content.stitchSublayouts else { return XCTFail() }
            guard x2.count == 2 else { return XCTFail() }
            XCTAssertEqual(x2[0].frame, CGRect(horizontal: 0, vertical: 100 - 10, horizontal: 10, vertical: 20))
            XCTAssertEqual(x2[1].frame, CGRect(horizontal: 10, vertical: 0, horizontal: 90, vertical: 200))
        }
        do {
            let p = Piece(sizing: .fillContainer, content: .stitch(Stitch(version: 1, content: {
                StitchContent(axis: .horizontal, segments: [
                    Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(horizontal: 10, vertical: 20), color: .red))),
                    Piece(sizing: .fillContainer, content: .stitch(Stitch(version: 2, content: {
                        StitchContent(axis: .vertical, segments: [
                            Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: .zero, color: .green))),
                            Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: .zero, color: .blue))),
                        ])
                    }))),
                ])
            })))
            let p1 = ResolvedPiece(from: p)
            let p2 = p1.layout(in: CGRect(horizontal: 0, vertical: 0, horizontal: 100, vertical: 200))
            XCTAssertEqual(p2.frame, CGRect(horizontal: 0, vertical: 0, horizontal: 100, vertical: 200))
            guard let x2 = p2.content.stitchSublayouts else { return XCTFail() }
            guard x2.count == 2 else { return XCTFail() }
            XCTAssertEqual(x2[0].frame, CGRect(horizontal: 0, vertical: 100 - 10, horizontal: 10, vertical: 20))
            XCTAssertEqual(x2[1].frame, CGRect(horizontal: 10, vertical: 0, horizontal: 90, vertical: 200))
            guard let x3 = x2[1].content.stitchSublayouts else { return XCTFail() }
            guard x3.count == 2 else { return XCTFail() }
            XCTAssertEqual(x3[0].frame, CGRect(horizontal: 0, vertical: 0, horizontal: 90, vertical: 100))
            XCTAssertEqual(x3[1].frame, CGRect(horizontal: 0, vertical: 100, horizontal: 90, vertical: 100))
        }
    }
    func testStack() {
        do {
            let p = Piece(sizing: .fitContent, content: .stack(Stack(version: 1, content: { [
                Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(horizontal: 20, vertical: 20), color: .red))),
                Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(horizontal: 40, vertical: 40), color: .green))),
                Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(horizontal: 60, vertical: 60), color: .blue))),
            ]})))
            let p1 = ResolvedPiece(from: p)
            let p2 = p1.layout(in: CGRect(horizontal: 0, vertical: 0, horizontal: 100, vertical: 100))
            XCTAssertEqual(p2.frame, CGRect(horizontal: 50 - 30, vertical: 50 - 30, horizontal: 60, vertical: 60))
            guard let x2 = p2.content.stackSublayouts else { return XCTFail() }
            guard x2.count == 3 else { return XCTFail() }
            XCTAssertEqual(x2[0].frame, CGRect(horizontal: 30 - 10, vertical: 30 - 10, horizontal: 20, vertical: 20))
            XCTAssertEqual(x2[1].frame, CGRect(horizontal: 30 - 20, vertical: 30 - 20, horizontal: 40, vertical: 40))
            XCTAssertEqual(x2[2].frame, CGRect(horizontal: 30 - 30, vertical: 30 - 30, horizontal: 60, vertical: 60))
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
