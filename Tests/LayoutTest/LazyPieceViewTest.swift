#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

@MainActor
final class LazyPieceViewTest: XCTestCase {
    func testSinglePiece() {
        guard #available(iOS 15, *) else { return XCTFail("iOS <15 is not supported for testing target.") }
        let a = LazyPieceView()
        let b = Color(.red, size: CGSize(width: 8, height: 8))
        a.piece = b.piece
        XCTAssertEqual(a.sizeThatFits(.zero), CGSize(width: 8, height: 8))
        a.sizeToFit()
        XCTAssertEqual(a.frame, CGRect(x: 0, y: 0, width: 8, height: 8))
        assertSnapshot(matching: a, as: .image)
    }
    func testNestedComposition() {
        guard #available(iOS 15, *) else { return XCTFail("iOS <15 is not supported for testing target.") }
        let a = LazyPieceView()
        let b = StitchY {
            StitchX {
                Color(.red, size: CGSize(width: 8, height: 8))
                Color(.green, size: CGSize(width: 8, height: 8))
                Color(.blue, size: CGSize(width: 8, height: 8))
            }
            StitchX {
                Color(.gray, size: CGSize(width: 8, height: 8))
            }
        }
        a.backgroundColor = .white
        a.piece = b.piece
        XCTAssertEqual(a.sizeThatFits(.zero), CGSize(width: 24, height: 16))
        a.sizeToFit()
        XCTAssertEqual(a.frame, CGRect(x: 0, y: 0, width: 24, height: 16))
        assertSnapshot(matching: a, as: .image)
    }
    func testLazyResizing() {
        final class MockView: UIView, LazyResizingView {
            var definedSize = CGSize.zero { didSet { delegate?(.needsResizing) } }
            override func sizeThatFits(_ size: CGSize) -> CGSize { definedSize }
            var delegate = nil as Delegate?
        }
        let m = MockView()
        m.backgroundColor = .red
        m.definedSize = CGSize(width: 8, height: 8)
        
        let a = LazyPieceView()
        var resizeNoteReceived = false
        a.delegate = { note in
            resizeNoteReceived = true
        }
        a.piece = LazyPiece.content(LazyPieceContent(
            typeID: ObjectIdentifier(MockView.self),
            make: { m },
            update: noop))
        XCTAssertEqual(a.frame, CGRect(x: 0, y: 0, width: 0, height: 0))
        a.sizeToFit()
        XCTAssertEqual(a.frame, CGRect(x: 0, y: 0, width: 8, height: 8))
        assertSnapshot(matching: a, as: .image)
        XCTAssertEqual(a.frame, CGRect(x: 0, y: 0, width: 8, height: 8))
        
        XCTAssertFalse(resizeNoteReceived)
        resizeNoteReceived = false
        m.backgroundColor = .green
        /// Setting `definedSize` triggers delegate set above and so calls `a?.sizeToFit()`.
        m.definedSize = CGSize(width: 16, height: 8)
        XCTAssertTrue(resizeNoteReceived)
        XCTAssertEqual(a.frame, CGRect(x: 0, y: 0, width: 8, height: 8))
        a.sizeToFit()
        XCTAssertEqual(a.frame, CGRect(x: 0, y: 0, width: 16, height: 8))
        assertSnapshot(matching: a, as: .image)
        XCTAssertEqual(a.frame, CGRect(x: 0, y: 0, width: 16, height: 8))
    }
    
    func testTextRendering() async {
        let a = NSAttributedString(string: "ABC", attributes: [
            .font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
            .foregroundColor: UIColor.red,
        ])
        let b = await TextRendering.run(params: TextRendering.Params(
            pointScaleInPixels: 1,
            containerSize: nil,
            lazyTextContent: { a }))
        switch b {
        case .failure:
            XCTFail()
        case let .success(product):
            XCTAssertNotNil(product.bitmapImage)
            guard let bitmapImage = product.bitmapImage else { return }
            XCTAssert(bitmapImage.width > 0)
            XCTAssert(bitmapImage.height > 0)
            let image = UIImage(cgImage: bitmapImage, scale: 1, orientation: .up)
            assertSnapshot(matching: image, as: .image)
        }
    }
    func testLazyTextView() async {
        let a = LazyTextView()
        var recv = false
        a.backgroundColor = .white
        a.delegate = { note in recv = true }
        a.text = NSAttributedString(string: "ABC", attributes: [
            .font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
            .foregroundColor: UIColor.red,
        ])
        assert(a.smallestFittingSize.width == 0)
        assert(a.smallestFittingSize.height == 0)
        while !recv {
            await Task.yield()
        }
        XCTAssert(a.smallestFittingSize.width > 0)
        XCTAssert(a.smallestFittingSize.height > 0)
        assertSnapshot(matching: a, as: .image)
    }
}

@resultBuilder
private struct LazyPieceBuilder {
    static func buildBlock(_ components: LazyPiece...) -> [LazyPiece] {
        components
    }
    static func buildExpression(_ expression: LazyPieceConvertible) -> LazyPiece {
        expression.piece
    }
}
private protocol LazyPieceConvertible {
    var piece: LazyPiece { get }
}
private struct StitchX: LazyPieceConvertible {
    let piece: LazyPiece
    init(@LazyPieceBuilder contents: () -> [LazyPiece]) {
        piece = .stitch(LazyPieceStitch(axis: .x, layout: .tightCentering, items: contents())) 
    }
}
private struct StitchY: LazyPieceConvertible {
    let piece: LazyPiece
    init(@LazyPieceBuilder contents: () -> [LazyPiece]) {
        piece = .stitch(LazyPieceStitch(axis: .y, layout: .tightCentering, items: contents()))
    }
}
private struct Color: LazyPieceConvertible {
    let piece: LazyPiece
    init(_ c:UIColor, size z:CGSize) {
        piece = .content(.color(c, size: z))
    }
}
#endif
