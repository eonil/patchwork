import Patchwork
import UIKit

@resultBuilder
struct LazyPieceBuilder {
    static func buildBlock(_ components: LazyPiece...) -> [LazyPiece] {
        components
    }
    static func buildExpression(_ expression: LazyPieceConvertible) -> LazyPiece {
        expression.piece
    }
}
protocol LazyPieceConvertible {
    var piece: LazyPiece { get }
}
struct StitchX: LazyPieceConvertible {
    let piece: LazyPiece
    init(@LazyPieceBuilder contents: () -> [LazyPiece]) {
        piece = .stitch(LazyPieceStitch(axis: .x, layout: .tightCentering, items: contents()))
    }
}
struct StitchY: LazyPieceConvertible {
    let piece: LazyPiece
    init(@LazyPieceBuilder contents: () -> [LazyPiece]) {
        piece = .stitch(LazyPieceStitch(axis: .y, layout: .tightCentering, items: contents()))
    }
}

struct Color: LazyPieceConvertible {
    let piece: LazyPiece
    init(_ c:UIColor, size z:CGSize) {
        piece = .content(.color(c, size: z))
    }
}

struct Text: LazyPieceConvertible {
    let piece: LazyPiece
    init(_ s:String, alignment a:NSTextAlignment, font f:UIFont, color c:UIColor) {
        piece = LazyPiece.content(.text(s, alignment: a, font: f, color: c))
    }
}

