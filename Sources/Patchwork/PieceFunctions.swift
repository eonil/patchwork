import Foundation
import CoreGraphics

/// Experimental piece functions.
/// - Design is unstable.
/// - No ideal solution for now.
/// - Define your own functions in your program if you need one now.

internal func divX(version v:AnyHashable = AlwaysDifferent(), vertical h: PieceSizingMode = .fillContainer, @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: PieceSizing(horizontal: .fillContainer, vertical: h), content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .horizontal, segments: c())
    })))
}
internal func divY(version v:AnyHashable = AlwaysDifferent(), horizontal w: PieceSizingMode = .fillContainer, @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: PieceSizing(horizontal: w, vertical: .fillContainer), content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .vertical, segments: c())
    })))
}
internal func stackZ(version x:AnyHashable = AlwaysDifferent(), horizontal h: PieceSizingMode = .fillContainer, vertical v: PieceSizingMode = .fillContainer, @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(horizontal: h, vertical: v, content: .stack(Stack(version: x, content: {
        c()
    })))
}

internal func fill(_ p:@escaping() -> Piece) -> Piece {
    var z = p()
    z.sizing.horizontal = .fillContainer
    z.sizing.vertical = .fillContainer
    return z
}
internal func fillX(_ p:@escaping() -> Piece) -> Piece {
    var z = p()
    z.sizing.horizontal = .fillContainer
    return z
}
internal func fillY(_ p:@escaping() -> Piece) -> Piece {
    var z = p()
    z.sizing.vertical = .fillContainer
    return z
}

/// Makes contained piece as fit-content mode.
internal func fit(_ p:@escaping() -> Piece) -> Piece {
    var z = p()
    z.sizing.horizontal = .fitContent
    z.sizing.vertical = .fitContent
    return z
}
internal func fitX(_ p:@escaping() -> Piece) -> Piece {
    var z = p()
    z.sizing.horizontal = .fitContent
    return z
}
internal func fitY(_ p:@escaping() -> Piece) -> Piece {
    var z = p()
    z.sizing.vertical = .fitContent
    return z
}

/// It's unclear that this function is well-designed or not.
@available(*, deprecated)
internal func wrapX(version v:AnyHashable = AlwaysDifferent(), @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: .fitContent, content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .horizontal, segments: c())
    })))
}
/// It's unclear that this function is well-designed or not.
@available(*, deprecated)
internal func wrapY(version v:AnyHashable = AlwaysDifferent(), @ArrayBuilder<Piece> content c:@escaping() -> [Piece]) -> Piece {
    Piece(sizing: .fitContent, content: .stitch(Stitch(version: v, content: {
        StitchContent(axis: .vertical, segments: c())
    })))
}

internal func view(_ x:OSView) -> Piece {
    Piece(sizing: .fillContainer, content: .view(x))
}
internal func text(_ x:NSAttributedString) -> Piece {
    Piece(sizing: .fillContainer, content: .text(x))
}
internal func image(_ x:OSImage) -> Piece {
    Piece(sizing: .fillContainer, content: .image(x))
}
/// Flex sized color.
internal func color(_ x:OSColor) -> Piece {
    Piece(sizing: .fillContainer, content: .color(ColorPieceContent(size: .zero, color: x)))
}
/// Flex sized space.
internal func space() -> Piece {
    Piece(sizing: .fillContainer, content: .space(.zero))
}



/// Rigid sized color.
internal func fitColor(_ x:OSColor, width w:CGFloat, height h:CGFloat) -> Piece {
    Piece(sizing: .fitContent, content: .color(ColorPieceContent(size: CGSize(width: w, height: h), color: x)))
}
/// Rigid sized space.
internal func fitSpace(width w:CGFloat, height h:CGFloat) -> Piece {
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

