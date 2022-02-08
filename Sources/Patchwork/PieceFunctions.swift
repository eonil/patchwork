import Foundation
import CoreGraphics

public func divX(version v:AnyHashable = AlwaysDifferent(), vertical h: PieceSizingMode = .fillContainer, @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: PieceSizing(horizontal: .fillContainer, vertical: h), content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .horizontal, segments: c())
    })))
}
public func divY(version v:AnyHashable = AlwaysDifferent(), horizontal w: PieceSizingMode = .fillContainer, @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: PieceSizing(horizontal: w, vertical: .fillContainer), content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .vertical, segments: c())
    })))
}
public func stackZ(version x:AnyHashable = AlwaysDifferent(), horizontal h: PieceSizingMode = .fillContainer, vertical v: PieceSizingMode = .fillContainer, @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(horizontal: h, vertical: v, content: .stack(Stack(version: x, content: {
        c()
    })))
}

public func fill(_ p:@escaping() -> Piece) -> Piece {
    var z = p()
    z.sizing.horizontal = .fillContainer
    z.sizing.vertical = .fillContainer
    return z
}
public func fillX(_ p:@escaping() -> Piece) -> Piece {
    var z = p()
    z.sizing.horizontal = .fillContainer
    return z
}
public func fillY(_ p:@escaping() -> Piece) -> Piece {
    var z = p()
    z.sizing.vertical = .fillContainer
    return z
}

/// Makes contained piece as fit-content mode.
public func fit(_ p:@escaping() -> Piece) -> Piece {
    var z = p()
    z.sizing.horizontal = .fitContent
    z.sizing.vertical = .fitContent
    return z
}
public func fitX(_ p:@escaping() -> Piece) -> Piece {
    var z = p()
    z.sizing.horizontal = .fitContent
    return z
}
public func fitY(_ p:@escaping() -> Piece) -> Piece {
    var z = p()
    z.sizing.vertical = .fitContent
    return z
}

/// It's unclear that this function is well-designed or not.
@available(*, deprecated)
public func wrapX(version v:AnyHashable = AlwaysDifferent(), @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: .fitContent, content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .horizontal, segments: c())
    })))
}
/// It's unclear that this function is well-designed or not.
@available(*, deprecated)
public func wrapY(version v:AnyHashable = AlwaysDifferent(), @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: .fitContent, content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .vertical, segments: c())
    })))
}

public func view(_ x:OSView) -> Piece {
    Piece(sizing: .fillContainer, content: .view(x))
}
public func text(_ x:NSAttributedString) -> Piece {
    Piece(sizing: .fillContainer, content: .text(x))
}
public func image(_ x:OSImage) -> Piece {
    Piece(sizing: .fillContainer, content: .image(x))
}
/// Flex sized color.
public func color(_ x:OSColor) -> Piece {
    Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: .zero, color: x)))
}
/// Flex sized space.
public func space() -> Piece {
    Piece(sizing: .fillContainer, content: .space(.zero))
}



/// Rigid sized color.
public func fitColor(_ x:OSColor, width w:CGFloat, height h:CGFloat) -> Piece {
    Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(width: w, height: h), color: x)))
}
/// Rigid sized space.
public func fitSpace(width w:CGFloat, height h:CGFloat) -> Piece {
    Piece(sizing: .fitContent, content: .space(CGSize(width: w, height: h)))
}



@resultBuilder
public struct ArrayBuilder<Element> {
    public static func buildBlock(_ components: Element...) -> [Element] { components }
    public static func buildBlock(_ components: [Element]) -> [Element] { components }
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

