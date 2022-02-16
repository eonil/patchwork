import Foundation
import CoreGraphics

struct ResolvedPiece {
    var sizing = PieceSizing(horizontal: .fitContent, vertical: .fitContent)
    var content = ResolvedPieceContent.space(.zero)
}
enum ResolvedPieceContent {
    case stitch(ResolvedStitch)
    case stack(ResolvedStack)
    case view(ResolvedView)
    case text(ResolvedText)
    case image(OSImage)
    case color(ColorPieceContent)
    case space(CGSize)
}
struct ResolvedStitch {
    private(set) var version: AnyHashable
    private(set) var axis = StitchAxis.vertical
    private(set) var segments = [ResolvedPiece]()
    private(set) var precomputedFittingSize = CGSize.zero
}
struct ResolvedStack {
    private(set) var version: AnyHashable
    private(set) var slices = [ResolvedPiece]()
    private(set) var precomputedFittingSize = CGSize.zero
}
struct ResolvedView {
    let view: OSView
    let precomputedFittingSize: CGSize
}
struct ResolvedText {
    let text: NSAttributedString
    let precomputedFittingSize: CGSize
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
            
        case let (.stack(a), .stack(b)):
            return ResolvedPiece(sizing: new.sizing, content: .stack(a.updated(with: b)))
        case let (_, .stack(b)):
            return ResolvedPiece(sizing: new.sizing, content: .stack(ResolvedStack(from: b)))
            
        case let (_, .view(b)):
            return ResolvedPiece(sizing: new.sizing, content: .view(ResolvedView(view: b, precomputedFittingSize: b.pieceFittingSize)))
            
        case let (_, .text(b)):
            return ResolvedPiece(sizing: new.sizing, content: .text(ResolvedText(text: b, precomputedFittingSize: b.size())))
            
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
        let segs = c.segments.enumerated().map({ i,p -> ResolvedPiece in
            let old = segments.indices.contains(i) ? segments[i] : ResolvedPiece()
            let new = old.updated(with: p)
            return new
        })
        return ResolvedStitch(
            version: x.version,
            axis: c.axis,
            segments: segs,
            precomputedFittingSize: ResolvedStitch.computeFittingSize(axis: c.axis, segments: segs))
    }
    static func computeFittingSize(axis: StitchAxis, segments: [ResolvedPiece]) -> CGSize {
        switch axis {
        case .horizontal:   return segments.lazy.map(\.content.pieceFittingSize).reduce(.zero, composeX)
        case .vertical:     return segments.lazy.map(\.content.pieceFittingSize).reduce(.zero, composeY)
        }
    }
}
extension ResolvedStack {
    init(from x:Stack) {
        version = AnyHashable(AlwaysDifferent())
        self = updated(with: x)
    }
    func updated(with x:Stack) -> ResolvedStack {
        guard version != x.version else { return self }
        let c = x.content()
        let ss = c.enumerated().map({ i,p -> ResolvedPiece in
            let old = slices.indices.contains(i) ? slices[i] : ResolvedPiece()
            let new = old.updated(with: p)
            return new
        })
        return ResolvedStack(
            version: x.version,
            slices: ss,
            precomputedFittingSize: ResolvedStack.computeFittingSize(slices: ss))
    }
    static func computeFittingSize(slices:[ResolvedPiece]) -> CGSize {
        slices.map(\.content.pieceFittingSize).reduce(.zero, perAxisMax)
    }
}




