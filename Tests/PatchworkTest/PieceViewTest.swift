#if canImport(UIKit)
import XCTest
import SnapshotTesting
@testable import Patchwork

final class PieceViewTest: XCTestCase {
    func testHappyCase() {
        do {
            let a = PieceView()
            let b = Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(horizontal: 20, vertical: 40), color: .white)))
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, horizontal: 100, vertical: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = Piece(sizing: .fitContent, content: .stitch(Stitch(
                version: AnyHashable(AlwaysDifferent()),
                content: {
                    StitchContent(axis: .x, segments: [
                        Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: CGSize(horizontal: 10, vertical: 10), color: .red))),
                        Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: CGSize(horizontal: 10, vertical: 10), color: .green))),
                        Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: CGSize(horizontal: 10, vertical: 10), color: .blue))),
                    ])
                })))
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, horizontal: 100, vertical: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = Piece(sizing: .fillContainer, content: .stitch(Stitch(
                version: AnyHashable(AlwaysDifferent()),
                content: {
                    StitchContent(axis: .x, segments: [
                        Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: CGSize(horizontal: 10, vertical: 10), color: .red))),
                        Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: CGSize(horizontal: 10, vertical: 10), color: .green))),
                        Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: CGSize(horizontal: 10, vertical: 10), color: .blue))),
                    ])
                })))
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, horizontal: 100, vertical: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = Piece(sizing: .fillContainer, content: .stitch(Stitch(
                version: AnyHashable(AlwaysDifferent()),
                content: {
                    StitchContent(axis: .x, segments: [
                        Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(horizontal: 10, vertical: 10), color: .red))),
                        Piece(sizing: .fillContainer, content: .stitch(Stitch(version: AnyHashable(AlwaysDifferent()), content: {
                            StitchContent(axis: .x, segments: [
                                Piece(sizing: .fillContainer, content: .space(.zero)),
                                Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: CGSize(horizontal: 10, vertical: 10), color: .green))),
                                Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: CGSize(horizontal: 10, vertical: 10), color: .blue))),
                            ])
                        }))),
                        
                    ])
                })))
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, horizontal: 100, vertical: 100)
            assertSnapshot(matching: a, as: .image)
        }
        do {
            let a = PieceView()
            let b = Piece(sizing: .fitContent, content: .stack(Stack(version: 1, content: { [
                Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(horizontal: 20, vertical: 20), color: .red.withAlphaComponent(0.5)))),
                Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(horizontal: 40, vertical: 40), color: .green.withAlphaComponent(0.5)))),
                Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(horizontal: 60, vertical: 60), color: .blue.withAlphaComponent(0.5)))),
            ]})))
            a.backgroundColor = .black
            a.piece = b
            a.frame = CGRect(x: 0, y: 0, horizontal: 100, vertical: 100)
            assertSnapshot(matching: a, as: .image)
        }
    }
    
    func testSimplePieceUpdateInPlace() {
        let v = PieceView()
        v.frame = CGRect(x: 0, y: 0, horizontal: 100, vertical: 100)
        v.piece = color(.red)
        assertSnapshot(matching: v, as: .image)
        
        v.piece = color(.blue)
        assertSnapshot(matching: v, as: .image)
    }
    func testStitchPieceUpdateInPlace() {
        let v = PieceView()
        v.frame = CGRect(x: 0, y: 0, horizontal: 100, vertical: 100)
        v.piece = divX {
            color(.red, horizontal: 10, vertical: 10)
            color(.blue)
        }
        assertSnapshot(matching: v, as: .image)
        
        v.piece = divX {
            color(.red)
            color(.green, horizontal: 10, vertical: 10)
        }
        assertSnapshot(matching: v, as: .image)
    }
    func testStackPieceUpdateInPlace() {
        let v = PieceView()
        v.frame = CGRect(x: 0, y: 0, horizontal: 100, vertical: 100)
        v.piece = stackZ {
            color(.red)
            color(.green, horizontal: 20, vertical: 20)
        }
        assertSnapshot(matching: v, as: .image)
        
        v.piece = stackZ {
            color(.red)
            color(.blue, horizontal: 80, vertical: 80)
        }
        assertSnapshot(matching: v, as: .image)
    }
}

#endif
