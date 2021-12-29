import Foundation
import CoreGraphics

public func divX(version v:AnyHashable = AlwaysDifferent(), height h: PieceSizingMode = .fillContainer, @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: PieceSizing(horizontal: .fillContainer, vertical: h), content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .x, segments: c())
    })))
}
public func divY(version v:AnyHashable = AlwaysDifferent(), width w: PieceSizingMode = .fillContainer, @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: PieceSizing(horizontal: w, vertical: .fillContainer), content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .y, segments: c())
    })))
}
public func stackZ(version v:AnyHashable = AlwaysDifferent(), width w: PieceSizingMode = .fillContainer, height h: PieceSizingMode = .fillContainer, @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(x: w, height: h, content: .stack(Stack(version: v, content: {
        c()
    })))
}

public func wrapX(version v:AnyHashable = AlwaysDifferent(), @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: .fitContent, content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .x, segments: c())
    })))
}
public func wrapY(version v:AnyHashable = AlwaysDifferent(), @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: .fitContent, content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .y, segments: c())
    })))
}

public func view(_ x:OSView) -> Piece {
    Piece(sizing: .fitContent, content: .view(x))
}
public func text(_ x:NSAttributedString) -> Piece {
    Piece(sizing: .fitContent, content: .text(x))
}
public func image(_ x:OSImage) -> Piece {
    Piece(sizing: .fitContent, content: .image(x))
}
/// Flex sized color.
public func color(_ x:OSColor) -> Piece {
    Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: .zero, color: x)))
}
/// Rigid sized color.
public func color(_ x:OSColor, width w:CGFloat, height h:CGFloat) -> Piece {
    Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(width: w, height: h), color: x)))
}
/// Flex sized space.
public func space() -> Piece {
    Piece(sizing: .fillContainer, content: .space(.zero))
}
/// Rigid sized space.
public func space(width w:CGFloat, height h:CGFloat) -> Piece {
    Piece(sizing: .fitContent, content: .space(CGSize(width: w, height: h)))
}


@resultBuilder
public struct ArrayBuilder<Element> {
    public static func buildBlock(_ components: Element...) -> [Element] { components }
//    public static func buildBlock(_ components: [Element]...) -> [Element] { components.flatMap({ $0 }) }
//    public static func buildBlock<A:ArrayConvertible>(_ components: A...) -> [Element] where A.Element == Element { components.flatMap(\.array) }
//    public static func buildArray(_ components: [Element]) -> [Element] { components }
//    public static func buildArray(_ components: [[Element]]) -> [Element] { components.flatMap({ $0 }) }
}
//public protocol ArrayConvertible {
//    associatedtype Element
//    var array: [Element] { get }
//}
//extension Piece: ArrayConvertible {
//    public var array: [Piece] { [self] }
//}
//extension Array: ArrayConvertible where Element == Piece {
//    public var array: [Piece] { self }
//}
