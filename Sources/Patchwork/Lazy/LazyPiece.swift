import CoreGraphics

/// Piece layout gen. 3.
/// - Fully supports lazily resolved content sizes.
///   - Notifies root view object for resize. You can perform repositioning.
///   - Auto Layout will be applied automatically.
/// - Fit-to-content layout by default.
/// - Layout algorithm is fully customizable.
public enum LazyPiece {
    case content(LazyPieceContent)
    case stitch(LazyPieceStitch)
}
