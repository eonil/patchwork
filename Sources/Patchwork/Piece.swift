import Foundation
import CoreGraphics

/// Defines a unit of stitching.
///
/// All pieces have defined "fitting size".
/// The "fitting size" is piece's preferred minimal size that can present its content properly.
///
/// The "fitting size will be respected and kept by layout engine if the piece's sizing mode is set to `.fitContent`.
/// In this case, the piece's size is effectievly defined by content.
///
/// Otherwise (`.fillContainer`), the container defines piece's size.
/// In this case, "fitting size" is no longer respected, and the piece can be smaller or larger than its "fitting size".
///
public struct Piece {
    public var sizing: PieceSizing
    public var content: PieceContent
    public init(horizontal x:PieceSizingMode, vertical y:PieceSizingMode, content c: PieceContent) {
        sizing = PieceSizing(horizontal: x, vertical: y)
        content = c
        assertValidity()
    }
    public init(sizing s:PieceSizingMode, content c: PieceContent) {
        sizing = PieceSizing(horizontal: s, vertical: s)
        content = c
        assertValidity()
    }
    public init(sizing s:PieceSizing, content c: PieceContent) {
        sizing = s
        content = c
        assertValidity()
    }
}
public struct PieceSizing: Equatable {
    public var horizontal = PieceSizingMode.fitContent
    public var vertical = PieceSizingMode.fitContent
    public init(horizontal h:PieceSizingMode, vertical v:PieceSizingMode) {
        horizontal = h
        vertical = v
    }
}
public enum PieceSizingMode: Equatable {
    /// Fits to minimum size of **content**.
    case fitContent
    /// Fills all available space defined by **container**.
    case fillContainer
}
public enum PieceContent {
    case stitch(Stitch)
    case stack(Stack)
    case view(OSView)
    /// A tex piece content.
    /// You have to cover all characters with an explicit font object.
    /// Otherwise, result undefined.
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
    public var axis = StitchAxis.vertical
    public var segments = [Piece]()
}
public enum StitchAxis {
    case horizontal
    case vertical
}





public struct Stack {
    public var version: AnyHashable
    public var content: () -> [Piece]
    public init(version v:AnyHashable, content c:@escaping() -> [Piece]) {
        version = v
        content = c
    }
}


