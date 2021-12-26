import UIKit

public struct Piece {
    public var sizing: PieceSizing
    public var content: PieceContent
    public init(sizing s:PieceSizing = .rigid, content c: PieceContent = .space(.zero)) {
        sizing = s
        content = c
    }
}
public enum PieceSizing {
    case rigid
    case flexible
}
public enum PieceContent {
    case stitch(Stitch)
//    case stack([Piece])
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
/// - Size of rigid segment will be respected and kept.
///   - Contents will underflow/overflow if container size is too small and if all segments are rigid.
/// - Flexible segments will be stretched/shrunk up to container size.
/// - Size of a stitch-view need to be set to its fitting-size to avoid content underflow/overflow.
///
/// - Segments with clearly defined size limits will not be stretched/shrunk.
///   - Layout system will respect their defined size and try to keep it as much as possible.
///   - If it's impossible to satisfy their defined size, layout system will issue a debug-time assertion failure, but keep running in release mode.
/// - Size of a stitch view is defined by its content.
/// - More flexibility is **not a goal**. Keep system simple as much as possible.
///   - If you need more flexibility, implement a custom layout view.
///
/// Version-based update.
/// -----------------
/// - All stitches can provide a version.
/// - Stitch view will update stitch contents only if their versions are different.
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

struct StitchContext {
    var availableSpaceSize: CGSize
    var segmentFittingSizes: [CGSize]
    var segmentFittingSizeSum: CGSize
    var segmentFittingSizeMax: CGSize
    var segmentSizings: [PieceSizing]
}
