import UIKit

struct ResolvedPiece {
    var sizing = PieceSizing.rigid
    var content = ResolvedPieceContent.space(.zero)
}
enum ResolvedPieceContent {
    case stitch(ResolvedStitch)
    case view(OSView)
    case text(NSAttributedString)
    case image(OSImage)
    case color(ColorPieceContent)
    case space(CGSize)
}
struct ResolvedStitch {
    private(set) var version: AnyHashable
    private(set) var axis = StitchAxis.y
    private(set) var segments = [ResolvedPiece]()
}





extension ResolvedPiece {
    init(from x:Piece) {
        self = updated(with: x)
    }
    func updated(with x:Piece) -> ResolvedPiece {
        let old = self
        let new = x
        switch (old.content, new.content) {
        case let (.stitch(a), .stitch(b)):
            return ResolvedPiece(sizing: new.sizing, content: .stitch(a.updated(with: b)))
            
        case let (_, .stitch(b)):
            return ResolvedPiece(sizing: new.sizing, content: .stitch(ResolvedStitch(from: b)))
            
        case let (_, .view(b)):
            return ResolvedPiece(sizing: new.sizing, content: .view(b))
            
        case let (_, .text(b)):
            return ResolvedPiece(sizing: new.sizing, content: .text(b))
            
        case let (_, .image(b)):
            return ResolvedPiece(sizing: new.sizing, content: .image(b))
            
        case let (_, .color(b)):
            return ResolvedPiece(sizing: new.sizing, content: .color(b))
            
        case let (_, .space(b)):
            return ResolvedPiece(sizing: new.sizing, content: .space(b))
        }
    }
}
extension ResolvedStitch {
    init(from x:Stitch) {
        version = AnyHashable(AlwaysDifferent())
        self = updated(with: x)
    }
    func updated(with x:Stitch) -> ResolvedStitch {
        guard version != x.version else { return self }
        let c = x.content()
        return ResolvedStitch(
            version: x.version,
            axis: c.axis,
            segments: c.segments.enumerated().map({ i,p in
                let old = segments.indices.contains(i) ? segments[i] : ResolvedPiece()
                let new = old.updated(with: p)
                return new
            }))
    }
}




