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
    /// Piece with a direct reference to a view instance.
    case view(OSView)
    /// A text piece content.
    /// You have to cover all characters with an explicit font object.
    /// Otherwise, result undefined.
    @available(*, deprecated, message: "single implementation cannot satisfy all needs. please define your own text rendering view")
    case text(NSAttributedString)
    case image(OSImage)
    case color(ColorPieceContent)
    case space(CGSize)
    case custom(CustomPieceContent)

    /// A piece with a custom view class.
    /// - Patchwork creates and maintain desired view instance.
    /// - Patchwork will re-use existing view instance for same `kind` value.
    /// - As Patchwork reuses same view instance, no on animation or performance issue arises.
    ///
    /// Type Detection
    /// -----------
    /// - We cannot detect final type of an Objective-C object statically. And `UIView`/`NSView` are all Objective-C objects.
    /// - Patchwork needs reliable way to identify type of this view.
    /// - This function accepts explicit `kind` parameter for it.
    /// - You can use any hashable value for this.
    /// - To use type information for `kind`, use `ObjectIdentifier(type(of: YourType.self))`.
    ///
    /// Caveats
    /// ------
    /// - It's your responsibility to return same type view instances for same `kind` value.
    /// - Otherwise, result undefined.
    ///
    /// - Warning:
    ///     Somehow, downcasting to `View` type doesn't work if `View` type is composition type such as `UIView & SomeProtocol`.
    ///     I suspect Swift compiler bug, though the reason is unclear.
    ///     Therefore, this cannot be used in user code.
    ///
    @available(*, deprecated, message: "doesn't work. use `.custom` directly and perform downcasting yourself")
    public static func view<View:OSView>(
        kind:AnyHashable,
        make:@escaping() -> View,
        step:@escaping(View) -> Void) -> PieceContent
    {
        .custom(CustomPieceContent(
            kind: kind,
            instantiate: { make() },
            update: { view in step(view as! View) }))
    }
}

/// Type-erased version of `CustomViewContent`.
/// - You are not supposed to use this type directly. Use `ViewPieceContent`.
public struct CustomPieceContent {
    var kind: AnyHashable
    var instantiate: () -> OSView
    var update: (OSView) -> Void
    public init(kind k: AnyHashable, instantiate m: @escaping () -> OSView, update x: @escaping (OSView) -> Void) {
        kind = k
        instantiate = m
        update = x
    }
}
public struct ColorPieceContent {
    public var size: CGSize
    public var color: OSColor
    public var cornerRadius: CGFloat
    public init(size s:CGSize, color c:OSColor, cornerRadius r:CGFloat = 0) {
        size = s
        color = c
        cornerRadius = r
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
    public init(axis a:StitchAxis, segments xs:[Piece]) {
        axis = a
        segments = xs
    }
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


