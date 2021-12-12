#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI

/// SwiftUI compatible versioin of `PieceView`.
/// - Provided only for compatibility reason.
public struct PieceViewRepresentation: UIViewRepresentable {
    var piece = Space()
    public func makeUIView(context: Context) -> PieceView {
        let v = PieceView()
        v.piece = piece
        return v
    }
    public func updateUIView(_ uiView: PieceView, context: Context) {
        uiView.piece = piece
    }
}
#endif
