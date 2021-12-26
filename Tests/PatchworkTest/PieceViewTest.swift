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
                        Piece(sizing: .flex, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .red))),
                        Piece(sizing: .flex, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .green))),
                        Piece(sizing: .flex, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .blue))),
                    ])
                })))
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = Piece(sizing: .flex, content: .stitch(Stitch(
                version: AnyHashable(AlwaysDifferent()),
                content: {
                    StitchContent(axis: .x, segments: [
                        Piece(sizing: .flex, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .red))),
                        Piece(sizing: .flex, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .green))),
                        Piece(sizing: .flex, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .blue))),
                    ])
                })))
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = Piece(sizing: .flex, content: .stitch(Stitch(
                version: AnyHashable(AlwaysDifferent()),
                content: {
                    StitchContent(axis: .x, segments: [
                        Piece(sizing: .rigid, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .red))),
                        Piece(sizing: .flex, content: .stitch(Stitch(version: AnyHashable(AlwaysDifferent()), content: {
                            StitchContent(axis: .x, segments: [
                                Piece(sizing: .flex, content: .space(.zero)),
                                Piece(sizing: .flex, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .green))),
                                Piece(sizing: .flex, content: .color(ColorPieceContent(size: CGSize(width: 10, height: 10), color: .blue))),
                            ])
                        }))),
                        
                    ])
                })))
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = Piece(sizing: .rigid, content: .stack(Stack(version: 1, content: { [
                Piece(sizing: .rigid, content: .color(ColorPieceContent(size: CGSize(width: 20, height: 20), color: .red.withAlphaComponent(0.5)))),
                Piece(sizing: .rigid, content: .color(ColorPieceContent(size: CGSize(width: 40, height: 40), color: .green.withAlphaComponent(0.5)))),
                Piece(sizing: .rigid, content: .color(ColorPieceContent(size: CGSize(width: 60, height: 60), color: .blue.withAlphaComponent(0.5)))),
            ]})))
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            assertSnapshot(matching: a, as: .image)
        }
    }
}

#endif
