import Foundation
import CoreGraphics

struct RenderingPieceLayout {
    var frame: CGRect
    var content: RenderingPieceContent
}
enum RenderingPieceContent {
    case stitch([RenderingPieceLayout])
    case stack([RenderingPieceLayout])
    case view(OSView)
    case text(NSAttributedString)
    case image(OSImage)
    case color(OSColor)
    case space
}



extension ResolvedPiece {
    /// Internal only function to place piece in a piece-view.
    func layout(in bounds:CGRect) -> RenderingPieceLayout {
        let x = ResolvedStitch(
            version: AnyHashable(AlwaysDifferent()), 
            axis: .horizontal,
            segments: [self],
            precomputedFittingSize: ResolvedStitch.computeFittingSize(axis: .horizontal, segments: [self]))
        return x.layout(in: bounds)[0]
    }
}
extension ResolvedPieceContent {
    var pieceFittingSize: CGSize {
        switch self {
        case let .stitch(x):    return x.precomputedFittingSize
        case let .stack(x):     return x.precomputedFittingSize
        case let .view(x):      return x.precomputedFittingSize
        case let .text(x):      return x.precomputedFittingSize
        case let .image(x):     return x.size
        case let .color(x):     return x.size
        case let .space(x):     return x
        }
    }
}

extension ResolvedStitch {
    func layout(in bounds:CGRect) -> [RenderingPieceLayout] {
        let segmentSizes: [CGSize]
        let segmentFrames: [CGRect]
        switch axis {
        case .horizontal:
            segmentSizes = horizontalStitchSizes(of: segments, in: bounds)
            segmentFrames = horizontalStitchingFrame(of: segmentSizes, in: bounds)
            
        case .vertical:
            segmentSizes = verticalStitchSizes(of: segments, in: bounds)
            segmentFrames = verticalStitchingFrame(of: segmentSizes, in: bounds)
        }
        return zip(segments,segmentFrames).map({ (p,f) in
            switch p.content {
            case let .stitch(x):
                return RenderingPieceLayout(frame: f, content: .stitch(x.layout(in: f.withOrigin(.zero))))
                
            case let .stack(x):
                return RenderingPieceLayout(frame: f, content: .stack(x.layout(in: f.withOrigin(.zero))))
                
            case let .view(x):
                return RenderingPieceLayout(frame: f, content: .view(x.view))
                
            case let .text(x):
                return RenderingPieceLayout(frame: f, content: .text(x.text))
                
            case let .image(x):
                return RenderingPieceLayout(frame: f, content: .image(x))
                
            case let .color(x):
                return RenderingPieceLayout(frame: f, content: .color(x.color))
                
            case .space:
                return RenderingPieceLayout(frame: f, content: .space)
            }
        })
    }
}

/// Resolves sizes of `segments` in `bounds`.
/// - Rigid segments will remain as they are.
/// - Flex segments with non-zero size will be scaled to fill the extra space.
/// - Flex segments with zero size will take equally portion of extra space.
///   - So, if there's any non-zero size segment, zero size segment won't be expanded.
private func horizontalStitchSizes(of segments:[ResolvedPiece], in bounds:CGRect) -> [CGSize] {
    var segmentSizes = segments.map(\.content.pieceFittingSize)
    let sumX = segmentSizes.widthSum()
    let extraX = bounds.width - sumX
    let flexIndicesX = segments.enumerated().filter({ _,p in p.sizing.horizontal == .fillContainer }).map(\.offset)
    let flexSumX = segmentSizes.widthSum(at: flexIndicesX)
    if flexSumX == 0 {
        /// All zero sized segment. Distribute extra space to all flex segments evenly.
        let perSegmentExtraX = extraX / CGFloat(flexIndicesX.count)
        for i in flexIndicesX {
            segmentSizes[i].width += perSegmentExtraX
        }
    }
    else {
        let flexScaleX = max(0, (flexSumX + extraX) / flexSumX)
        for (i,segment) in segments.enumerated() {
            if segment.sizing.horizontal == .fillContainer {
                segmentSizes[i].width *= flexScaleX
            }
        }
    }
    for i in segments.indices {
        if segments[i].sizing.vertical == .fillContainer {
            segmentSizes[i].height = bounds.height
        }
    }
    return segmentSizes
}
/// See `horizontalStitchSizes`.
private func verticalStitchSizes(of segments:[ResolvedPiece], in bounds:CGRect) -> [CGSize] {
    var segmentSizes = segments.map(\.content.pieceFittingSize)
    let sumY = segmentSizes.heightSum()
    let extraY = bounds.height - sumY
    let flexIndicesY = segments.enumerated().filter({ _,p in p.sizing.vertical == .fillContainer }).map(\.offset)
    let flexSumY = segmentSizes.heightSum(at: flexIndicesY)
    if flexSumY == 0 {
        /// All zero sized segment. Distribute extra space to all flex segments evenly.
        let perSegmentExtraY = extraY / CGFloat(flexIndicesY.count)
        for i in flexIndicesY {
            segmentSizes[i].height += perSegmentExtraY
        }
    }
    else {
        let flexScaleY = max(0, (flexSumY + extraY) / flexSumY)
        for (i,segment) in segments.enumerated() {
            if segment.sizing.vertical == .fillContainer {
                segmentSizes[i].height *= flexScaleY
            }
        }
    }
    for i in segments.indices {
        if segments[i].sizing.horizontal == .fillContainer {
            segmentSizes[i].width = bounds.width
        }
    }
    return segmentSizes
}

private func horizontalStitchingFrame(of sizes:[CGSize], in bounds:CGRect) -> [CGRect] {
    let sumX = sizes.widthSum()
    var x = bounds.minX + (bounds.width - sumX) / 2
    let y = bounds.midY
    var frames = [CGRect]()
    for size in sizes {
        let frame = CGRect(x: x, y: y - (size.height/2), width: size.width, height: size.height)
        frames.append(frame)
        x += size.width
    }
    return frames
}
private func verticalStitchingFrame(of sizes:[CGSize], in bounds:CGRect) -> [CGRect] {
    let sumY = sizes.heightSum()
    var y = bounds.minY + (bounds.height - sumY) / 2
    let x = bounds.midX
    var frames = [CGRect]()
    for size in sizes {
        let frame = CGRect(x: x - (size.width/2), y: y, width: size.width, height: size.height)
        frames.append(frame)
        y += size.height
    }
    return frames
}

private extension Array where Element == CGSize {
    func widthSum() -> CGFloat {
        var z = 0 as CGFloat
        for x in self { z += x.width }
        return z
    }
    func widthSum(at indices:[Int]) -> CGFloat {
        var z = 0 as CGFloat
        for i in indices { z += self[i].width }
        return z
    }
    func heightSum() -> CGFloat {
        var z = 0 as CGFloat
        for x in self { z += x.height }
        return z
    }
    func heightSum(at indices:[Int]) -> CGFloat {
        var z = 0 as CGFloat
        for i in indices { z += self[i].height }
        return z
    }
}





extension ResolvedStack {
    func layout(in bounds:CGRect) -> [RenderingPieceLayout] {
        let frames = slices.map { p -> CGRect in
            let fittingSize = p.content.pieceFittingSize
            let w = p.sizing.horizontal == .fitContent ? fittingSize.width : bounds.width
            let h = p.sizing.vertical == .fitContent ? fittingSize.height : bounds.height
            let v = CGVector(dx: w, dy: h)
            return bounds.midPoint.rect.inset(by: v.scaled(-0.5))
        }
        return zip(slices,frames).map({ (p,f) in
            switch p.content {
            case let .stitch(x):
                return RenderingPieceLayout(frame: f, content: .stitch(x.layout(in: f.withOrigin(.zero))))
                
            case let .stack(x):
                return RenderingPieceLayout(frame: f, content: .stack(x.layout(in: f.withOrigin(.zero))))
                
            case let .view(x):
                return RenderingPieceLayout(frame: f, content: .view(x.view))
                
            case let .text(x):
                return RenderingPieceLayout(frame: f, content: .text(x.text))
                
            case let .image(x):
                return RenderingPieceLayout(frame: f, content: .image(x))
                
            case let .color(x):
                return RenderingPieceLayout(frame: f, content: .color(x.color))
                
            case .space:
                return RenderingPieceLayout(frame: f, content: .space)
            }
        })
    }
}
