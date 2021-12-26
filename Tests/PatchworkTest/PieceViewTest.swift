#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class PieceViewTest: XCTestCase {
    func testHappyCase() {
        do {
            let a = PieceView()
            let b = Piece(sizing: .rigid, content: .color(ColorPieceContent(size: CGSize(width: 20, height: 40), color: .white)))
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = Piece(sizing: .rigid, content: .stitch(Stitch(
                version: AnyHashable(AlwaysDifferent()),
                content: {
                    StitchContent(axis: .x, segments: [
                        Piece(sizing: .flexible, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .red))),
                        Piece(sizing: .flexible, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .green))),
                        Piece(sizing: .flexible, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .blue))),
                    ])
                })))
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = Piece(sizing: .flexible, content: .stitch(Stitch(
                version: AnyHashable(AlwaysDifferent()),
                content: {
                    StitchContent(axis: .x, segments: [
                        Piece(sizing: .flexible, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .red))),
                        Piece(sizing: .flexible, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .green))),
                        Piece(sizing: .flexible, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .blue))),
                    ])
                })))
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = Piece(sizing: .flexible, content: .stitch(Stitch(
                version: AnyHashable(AlwaysDifferent()),
                content: {
                    StitchContent(axis: .x, segments: [
                        Piece(sizing: .rigid, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .red))),
                        Piece(sizing: .flexible, content: .stitch(Stitch(version: AnyHashable(AlwaysDifferent()), content: {
                            StitchContent(axis: .x, segments: [
                                Piece(sizing: .flexible, content: .space(.zero)),
                                Piece(sizing: .flexible, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .green))),
                                Piece(sizing: .flexible, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .blue))),
                            ])
                        }))),
                        
                    ])
                })))
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
    }
}

#endif
