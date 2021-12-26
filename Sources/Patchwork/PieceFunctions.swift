import Foundation
import CoreGraphics

public func divX(version v:AnyHashable = AlwaysDifferent(), @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: .flex, content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .x, segments: c())
    })))
}
public func divY(version v:AnyHashable = AlwaysDifferent(), @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: .flex, content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .y, segments: c())
    })))
}
public func stackZ(version v:AnyHashable = AlwaysDifferent(), @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: .flex, content: .stack(Stack(version: v, content: {
        c()
    })))
}

public func wrapX(version v:AnyHashable = AlwaysDifferent(), @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: .rigid, content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .x, segments: c())
    })))
}
public func wrapY(version v:AnyHashable = AlwaysDifferent(), @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: .rigid, content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .y, segments: c())
    })))
}

public func view(_ x:OSView) -> Piece {
    Piece(sizing: .rigid, content: .view(x))
}
public func text(_ x:NSAttributedString) -> Piece {
    Piece(sizing: .rigid, content: .text(x))
}
public func image(_ x:OSImage) -> Piece {
    Piece(sizing: .rigid, content: .image(x))
}
/// Flex sized color.
public func color(_ x:OSColor) -> Piece {
    Piece(sizing: .flex, content: .color(ColorPieceContent(size: .zero, color: x)))
}
/// Rigid sized color.
public func color(_ x:OSColor, width w:CGFloat, height h:CGFloat) -> Piece {
    Piece(sizing: .rigid, content: .color(ColorPieceContent(size: CGSize(width: w, height: h), color: x)))
}
/// Flex sized space.
public func space() -> Piece {
    Piece(sizing: .flex, content: .space(.zero))
}
/// Rigid sized space.
public func space(size s:CGSize) -> Piece {
    Piece(sizing: .rigid, content: .space(s))
}


@resultBuilder
struct ArrayBuilder<Element> {
    static func buildBlock(_ components: Element...) -> [Element] { components }
}
