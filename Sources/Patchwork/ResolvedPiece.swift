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
    case custom(ResolvedCustom)
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
struct ResolvedCustom {
    let kind: AnyHashable
    let view: OSView
    let precomputedFittingSize: CGSize
}



extension ResolvedPiece {
//    init(from x:Piece) {
//        self = updated(with: x)
//    }
    func updated(with x:Piece, config f:PieceViewConfig) -> ResolvedPiece {
        let old = self
        let new = x
        switch (old.content, new.content) {
        case let (.stitch(a), .stitch(b)):
            return ResolvedPiece(sizing: new.sizing, content: .stitch(a.updated(with: b, config: f)))
        case let (_, .stitch(b)):
            return ResolvedPiece(sizing: new.sizing, content: .stitch(ResolvedStitch(from: b, config: f)))
            
        case let (.stack(a), .stack(b)):
            return ResolvedPiece(sizing: new.sizing, content: .stack(a.updated(with: b, config: f)))
        case let (_, .stack(b)):
            return ResolvedPiece(sizing: new.sizing, content: .stack(ResolvedStack(from: b, config: f)))
            
        case let (_, .view(b)):
            return ResolvedPiece(sizing: new.sizing, content: .view(ResolvedView(view: b, precomputedFittingSize: b.pieceFittingSize)))
            
        case let (_, .text(b)):
            return ResolvedPiece(sizing: new.sizing, content: .text(ResolvedText(text: b, precomputedFittingSize: f.textSizeCeiling ? b.size().ceiling : b.size())))
            
        case let (_, .image(b)):
            return ResolvedPiece(sizing: new.sizing, content: .image(b))
            
        case let (_, .color(b)):
            return ResolvedPiece(sizing: new.sizing, content: .color(b))
            
        case let (_, .space(b)):
            return ResolvedPiece(sizing: new.sizing, content: .space(b))
        
        case let (.custom(a), .custom(b)):
            if a.kind == b.kind {
                b.update(a.view)
                return ResolvedPiece(sizing: new.sizing, content: .custom(ResolvedCustom(
                    kind: a.kind,
                    view: a.view,
                    precomputedFittingSize: a.view.pieceFittingSize)))
            }
            else {
                let v = b.instantiate()
                Test.increment(path: \.customViewInstantiationCount)
//                assert(type(of: v) == b.viewClass, "type of instantiated view `\(type(of: v))` is not same with expected type `\(b.viewClass)`")
                b.update(v)
                return ResolvedPiece(sizing: new.sizing, content: .custom(ResolvedCustom(
                    kind: b.kind,
                    view: v,
                    precomputedFittingSize: v.pieceFittingSize)))
            }
        case let (_, .custom(b)):
            let v = b.instantiate()
            Test.increment(path: \.customViewInstantiationCount)
//            assert(type(of: v) == b.viewClass, "type of instantiated view `\(type(of: v))` is not same with expected type `\(b.viewClass)`")
            b.update(v)
            return ResolvedPiece(sizing: new.sizing, content: .custom(ResolvedCustom(
                kind: b.kind,
                view: v,
                precomputedFittingSize: v.pieceFittingSize)))
        }
    }
}
extension ResolvedStitch {
    init(from x:Stitch, config f:PieceViewConfig) {
        version = AnyHashable(AlwaysDifferent())
        self = updated(with: x, config: f)
    }
    func updated(with x:Stitch, config:PieceViewConfig) -> ResolvedStitch {
        guard version != x.version else { return self }
        let c = x.content()
        let segs = c.segments.enumerated().map({ i,p -> ResolvedPiece in
            let old = segments.indices.contains(i) ? segments[i] : ResolvedPiece()
            let new = old.updated(with: p, config: config)
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
    init(from x:Stack, config f:PieceViewConfig) {
        version = AnyHashable(AlwaysDifferent())
        self = updated(with: x, config: f)
    }
    func updated(with x:Stack, config f: PieceViewConfig) -> ResolvedStack {
        guard version != x.version else { return self }
        let c = x.content()
        let ss = c.enumerated().map({ i,p -> ResolvedPiece in
            let old = slices.indices.contains(i) ? slices[i] : ResolvedPiece()
            let new = old.updated(with: p, config: f)
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




