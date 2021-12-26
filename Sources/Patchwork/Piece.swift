import UIKit

public struct Piece {
    public var sizing: PieceSizing
    public var content: PieceContent
    public init(sizing s:PieceSizingMode, content c: PieceContent) {
        sizing = PieceSizing(width: s, height: s)
        content = c
    }
    public init(sizing s:PieceSizing, content c: PieceContent) {
        sizing = s
        content = c
    }
}
public struct PieceSizing: Equatable {
    public var width = PieceSizingMode.rigid
    public var height = PieceSizingMode.rigid
    public init(width w:PieceSizingMode, height h:PieceSizingMode) {
        width = w
        height = h
    }
}
public enum PieceSizingMode: Equatable {
    case rigid
    case flex
}
public enum PieceContent {
    case stitch(Stitch)
    case stack(Stack)
    case view(OSView)
    case text(NSAttributedString)
    case image(OSImage)
    case color(ColorPieceContent)
    case space(CGSize)
}
public struct ColorPieceContent {
    public var size: CGSize
    public var color: OSColor
    public init(size s:CGSize, color c:OSColor) {
        size = s
        color = c
    }
}



/// Recursive composition of multiple contents in X/Y axis.
///
/// Layout
/// -------
/// - Two type of segments. Rigid or flexible.
/// - Size of rigid segment is defined by *content*.
///   - Defined size will be respected.
///   - Contents will underflow/overflow if container size is too small and if all segments are rigid.
///   - Make container large enough to prevent content overflow/underflow.
/// - Size of flexible segment is defined by *container*.
///   - Flexible segments will be stretched/shrunk up to container size.
///
/// Non-Goal
/// -------
/// - More feature is **not a goal**. Keep system simple as much as possible.
///   - If you need more flexibility, implement a custom layout view.
///
/// Version-Based Resolution
/// -------------------
/// - All stitches/stacks provides a version-based subtree resolution skipping.
/// - Subtrees will be resolved only if version has been changed.
/// - Once resolved subtree can be laid out different ways for different frames.
///
public struct Stitch {
    public var version: AnyHashable
    public var content: () -> StitchContent
    public init(version v:AnyHashable, content c:@escaping() -> StitchContent) {
        version = v
        content = c
    }
}
public struct StitchContent {
    public var axis = StitchAxis.y
    public var segments = [Piece]()
}
public enum StitchAxis {
    case x
    case y
}





public struct Stack {
    public var version: AnyHashable
    public var content: () -> [Piece]
    public init(version v:AnyHashable, content c:@escaping() -> [Piece]) {
        version = v
        content = c
    }
}


